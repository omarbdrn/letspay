# frozen_string_literal: true
# == Schema Information
#
# Table name: products
#
#  id                 :uuid             not null, primary key
#  merchant_reference :string
#  label              :string
#  amount_cents       :integer          default(0), not null
#  amount_currency    :string           default("USD"), not null
#  purchase_id        :uuid             not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  raw_amount_cents   :integer          default(0), not null
#

class Product < ApplicationRecord
  belongs_to :purchase

  has_one :share_product
  has_one :share, through: :share_product

  monetize :amount_cents
  monetize :raw_amount_cents, with_model_currency: :amount_currency

  def quantity
    share_product.try(:quantity)
  end

  def metadata
    JSON.parse share_product.try(:metadata)
  end

  def total_amount_cents(cart_amount_cents: nil)
    if variable_price
      applicable_price(cart_amount_cents)
    else
      quantity * amount_cents
    end
  end

  def asc_ordered_price_bounds
    return price_bounds unless price_bounds.all? { |e| e.key?('upper_bound') }

    price_bounds.sort_by { |e| e['upper_bound'] }
  end

  def applicable_price(cart_amount_cents)
    asc_ordered_price_bounds.each { |e| break e if e['upper_bound'] > cart_amount_cents }['price']
  end

  def in_cart?
    quantity.positive?
  end
end
