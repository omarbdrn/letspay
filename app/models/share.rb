# frozen_string_literal: true
# == Schema Information
#
# Table name: shares
#
#  id                :uuid             not null, primary key
#  email             :string           not null
#  purchase_id       :uuid             not null
#  account_id        :integer
#  amount_cents      :integer          default(0), not null
#  amount_currency   :string           default("USD"), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  payor_info_id     :integer
#  expired_at        :datetime
#  reminded_at       :datetime
#  service_fee_cents :integer          default(0), not null
#

class Share < ApplicationRecord

  EXPIRATION_TIME_IN_DAYS = 2
  HOURS_BETWEEN_REMINDER_AND_EXPIRATION = 24
  MULTICARD_LETSPAYER_PARTICIPATION_ROUND_IN_HOURS = 48

  belongs_to :payor_info, optional: true
  belongs_to :purchase, counter_cache: true
  belongs_to :account, optional: true

  has_one :merchant, through: :purchase
  has_one :operation,            -> { order(created_at: :desc).limit(1) }, as: :traceable
  has_one :pay_in,               -> { order(created_at: :desc).limit(1) }, as: :traceable
  has_one :pre_authorization,    -> { order(created_at: :desc).limit(1) }, as: :traceable
  has_one :refund,               -> { order(created_at: :desc).limit(1) }, as: :traceable

  has_many :pay_ins,             -> { order(created_at: :desc) }, as: :traceable
  has_many :pre_authorizations,  -> { order(created_at: :desc) }, as: :traceable
  has_many :refunds,             -> { order(created_at: :desc) }, as: :traceable
  has_many :transfers,           -> { order(created_at: :desc) }, as: :traceable
  has_many :operations,                                          as: :traceable
  has_many :share_products, dependent: :destroy
  has_many :products, through: :share_products
  has_many :successfull_pay_ins, -> { successfull },             as: :traceable, class_name: 'PayIn'

  monetize :amount_cents
  monetize :amount_to_pay_cents, with_model_currency: :amount_currency
  monetize :service_fee_cents, with_model_currency: :amount_currency

  validates :email, :purchase, presence: true
  validates :amount_cents, numericality: { greater_than: 0 }

  accepts_nested_attributes_for :payor_info, update_only: true

  delegate :first_name, :last_name, :full_name, :optin, to: :payor_info, allow_nil: true
  delegate :merchant_name, :leader_email, :leader_full_name, :merchant_picture_url, :merchant_slug, :merchant_white_label, :merchant_white_label_button_color, :shares_count, to: :purchase
  delegate :amount, :title, :description, to: :purchase, prefix: true
  delegate :first_name, :full_name, to: :payor_info, prefix: :payor
  delegate :api_key, to: :payor_info

  scope :unreminded, -> { where(reminded_at: nil) }
  scope :soon_to_expire, -> { not_expired.where('expired_at < ?', Time.current + HOURS_BETWEEN_REMINDER_AND_EXPIRATION.hours) }
  scope :multicard_soon_to_expire_for, ->(merchant) { not_expired.joins(:purchase).where("purchases.merchant_id = ?", merchant.id).where('expired_at < ?', Time.current + ((merchant.multicard_letspayer_participation_round_in_hours || 0) / 2.0).hours) }
  scope :not_expired, -> { where('expired_at > ?', Time.current) }
  scope :by_partial_email, ->(email_chunk) { where(email_matches(email_chunk)) }

  def paid?
    pay_in && pay_in.mango_status == Mango::SUCCEEDED_OPERATION_STATUS
  end

  def unpaid?
    !paid?
  end

  def refunded?
    refund && refund.mango_status == Mango::SUCCEEDED_OPERATION_STATUS
  end

  def purchase_initialize?
    purchase.state == 'INITIALIZED'
  end

  def purchase_waiting_merchant_validation?
    purchase.state == 'WAITING_MERCHANT_VALIDATION'
  end

  def pre_authorized?
    pre_authorization && pre_authorization.mango_status == Mango::SUCCEEDED_OPERATION_STATUS
  end

  def paid_at
    paid? ? pay_in.updated_at : nil
  end

  def pre_authorized_at
    pre_authorized? ? pre_authorization.updated_at : nil
  end

  def leader?
    purchase.leader_share == self
  end

  def pre_authorization_amount_cents
    (!merchant.multicard_mode? && leader?) ? purchase.amount_to_pay_cents : amount_to_pay_cents
  end

  def refunded_amount_cents
    refunds.try(:sum, :amount_cents) || 0
  end

  def refunded_amount
    Money.new(refunded_amount_cents, 'USD')
  end

  def last_operation
    operations.order(created_at: :desc).first
  end

  def self.email_matches(email_chunk)
    arel_table[:email].matches("%#{email_chunk}%")
  end

  def timezone
    payor_info.timezone || (!leader? && purchase.timezone) || PayorInfo::DEFAULT_TIMEZONE
  end

  def amount_to_pay_cents
    amount_cents + service_fee_cents
  end

  def single_share?
    purchase.shares.length == 1
  end

  def language
    payor_info.try(:language) || purchase.language
  end

  def share_expiration_time_in_days_from_now
    Share::EXPIRATION_TIME_IN_DAYS.days.from_now
  end

  def multicard_letspayer_participation_round_in_hours_from_now
    (purchase.merchant.try(:multicard_letspayer_participation_round_in_hours) || Share::MULTICARD_LETSPAYER_PARTICIPATION_ROUND_IN_HOURS).hours.from_now
  end

  def multicard_leader_last_chance_round_expired?
    multicard_leader_last_chance_round_expiration_time < Time.zone.now
  end

  def multicard_leader_last_chance_round_expiration_time
    expired_at + (purchase.merchant.try(:multicard_leader_last_chance_round_in_hours) || Share::MULTICARD_LETSPAYER_PARTICIPATION_ROUND_IN_HOURS).hours
  end

  def set_expiration!
    self.expired_at = purchase.merchant.multicard_mode? ? multicard_letspayer_participation_round_in_hours_from_now : share_expiration_time_in_days_from_now
  end

  def paid_amout
    successfull_pay_ins.sum(&:amount)
  end

  def paid_amout_cents
    successfull_pay_ins.sum(&:amount_cents)
  end

  def is_multicard?
    purchase.merchant.multicard_mode?
  end

  def purchase_cancelled?
    purchase.CANCELLED?
  end

  def is_manual_multicard?
    purchase.merchant.multicard_mode? && purchase.merchant.manual_multicard_mode?
  end

  def merchant_optin=(value)
    letspayer_merchant_optin = LetsPayerMerchantOptin.find_or_initialize_by(merchant: merchant, payor_info: payor_info)
    letspayer_merchant_optin.value = !!value
    letspayer_merchant_optin.save!
  end

  def products_in_cart
    products.select(&:in_cart?)
  end
end
