class Notification < ApplicationRecord
  belongs_to :account
  belongs_to :purchase

  validates :account, :purchase, presence: true
  validates :account, uniqueness: { scope: :purchase }
  validate :account_and_purchase_belongs_to_same_merchant


  private
  def account_and_purchase_belongs_to_same_merchant
    errors.add(:account_id, 'Account and purchase does not belong to the same merchant') unless self.account.merchants.include?(self.purchase.merchant)
  end
end
