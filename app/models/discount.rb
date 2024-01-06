# == Schema Information
#
# Table name: discounts
#
#  id              :integer          not null, primary key
#  start_date      :datetime
#  end_date        :datetime
#  merchant_id     :integer
#  amount_cents    :integer          default(0), not null
#  amount_currency :string           default("USD"), not null
#  code            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  percentage      :integer          default(0), not null
#  message         :string
#  display_message :boolean          default(FALSE)
#

class Discount < ApplicationRecord
  include ActionView::Helpers::NumberHelper

  belongs_to :merchant
  has_many :discount_purchases

  monetize :amount_cents

  validates :start_date, :end_date, :amount_cents, :code, presence: true
  validates :code, uniqueness: true
  validate :start_date_before_end_date, :is_percentage_or_amount, :is_percentage_if_merchant_dispatchable_cart

  scope :active, -> { where("start_date < ?", Time.current).where("end_date > ?", Time.current) }

  def is_percentage?
    percentage > 0
  end

  def compute_price(purchase_amount_cents)
    purchase_amount_cents * ( 1 - percentage / 100.0)
  end

  def active?
    Time.current > start_date && Time.current < end_date
  end

  def code_with_amount_or_percentage
    if is_percentage?
      "#{code} : #{percentage}%"
    else
      "#{code} : - #{number_to_currency(amount_cents / 100.0)}"
    end

  end

  private

  def start_date_before_end_date
    if start_date && end_date && start_date >= end_date
      errors.add(:start_date, "must be before end_date")
      errors.add(:end_date,   "must be after start_date")
    end
  end

  def is_percentage_or_amount
    if percentage > 0 && amount_cents > 0
      errors.add(:percentage,   "discount cannot be in percentage and amount at the same time")
      errors.add(:amount_cents, "discount cannot be in percentage and amount at the same time")
    end
    if percentage == 0 && amount_cents == 0
      errors.add(:percentage,   "discount amount or percentage must be greater than zero")
      errors.add(:amount_cents, "discount amount or percentage must be greater than zero")
    end
  end

  def is_percentage_if_merchant_dispatchable_cart
    if merchant.dispatchable_cart? && (amount_cents > 0 || percentage <= 0)
      errors.add(:amount_cents, "discount cannot be in amount if merchant dispatchable_cart is active")
    end
  end
end
