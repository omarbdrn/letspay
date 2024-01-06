# == Schema Information
#
# Table name: bank_accounts
#
#  id            :uuid             not null, primary key
#  merchant_id   :integer
#  iban          :string
#  bic           :string
#  owner_name    :string
#  owner_street  :string
#  owner_city    :string
#  owner_region  :string
#  owner_zipcode :string
#  owner_country :string
#  mango_id      :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class BankAccount < ApplicationRecord
  belongs_to :merchant

  validates :iban, :owner_name, :owner_street, :owner_city, :owner_region, :owner_zipcode, :owner_country, presence: true
  validate :iban_is_valid

  accepts_nested_attributes_for :merchant

  before_save :create_related_mango_bank_account

  def create_related_mango_bank_account
    if ENV['MANGO_SYNC_ENABLED'] && mango_field_did_change?
      request = Mango::BankAccount.new
      request.create(self)
      if request.success?
        true
      else
        logger.error { "bank_account=#{id} create_related_mango_bank_account=false reason=#{request.error_message}" }
        throw :abort
      end
    else
      true
    end
  end

  def mango_field_did_change?
    self.changes.keys.any?{|key| ["iban", "owner_name", "owner_street", "owner_city", "owner_region", "owner_zipcode", "owner_country"].include? key }
  end

  def merchant_attributes=(attributes)
    if attributes['id'].present?
      self.merchant = Merchant.find(attributes['id'])
    end
    super
  end

  def mango_valid?
    mango_id.present?
  end

  private

  def iban_is_valid
    errors.add(:iban, :invalid_iban) unless IBANTools::IBAN.valid? iban
  end

  def logger
    @logger ||= LetsPay::Logger.new(self.class.name)
  end

end
