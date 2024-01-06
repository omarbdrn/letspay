# == Schema Information
#
# Table name: discount_purchases
#
#  id          :uuid             not null, primary key
#  discount_id :integer
#  purchase_id :uuid
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class DiscountPurchase < ApplicationRecord
  belongs_to :discount
  belongs_to :purchase

  validates :discount, :purchase, presence: true
  validates :purchase, uniqueness: true # A purchase can only have one discount at a time

  after_create :apply_discount_on_purchase
  before_destroy :remove_discount_on_purchase

  def apply_discount_on_purchase
    purchase.update_attributes(amount_cents: discounted_purchase_price)
    apply_discount_on_products if purchase.merchant.dispatchable_cart?
  end

  def apply_discount_on_products
    purchase.products.each do |product|
      product.update_attributes(amount_cents: discouted_product_price(product))
    end
    correct_percentage_imprecision
  end

  def discounted_purchase_price
    if discount.is_percentage?
      discount.compute_price(purchase.raw_amount_cents)
    else
      purchase.raw_amount_cents - discount.amount_cents
    end
  end

  def discouted_product_price(product)
    if discount.is_percentage?
      discount.compute_price(product.raw_amount_cents)
    else
      product.raw_amount_cents - (discount.amount_cents * product.raw_amount_cents / product.purchase.raw_amount_cents)
    end
  end

  def correct_percentage_imprecision
    if purchase.products.sum(&:amount_cents) != purchase.amount_cents
      difference = purchase.amount_cents - purchase.products.sum(&:amount_cents)
      product = get_imprecision_source_product
      product.update_attributes(amount_cents: product.amount_cents + difference)
    end
  end

  def get_imprecision_source_product
    if discount.is_percentage?
      imprecision_distance = purchase.products.map{ |product| (100 * (100 - discount.percentage)) - ((10000 * product.amount_cents) / product.raw_amount_cents) }
      product_index = imprecision_distance.each_with_index.max[1]
      purchase.products[product_index] || purchase.products.first
    else
      purchase.products.first
    end
  end

  def remove_discount_on_purchase
    purchase.update_attributes(amount_cents: purchase.raw_amount_cents)
    remove_discount_on_products if purchase.merchant.dispatchable_cart?
  end

  def remove_discount_on_products
    purchase.products.each do |product|
      product.update_attributes(amount_cents: product.raw_amount_cents)
    end
  end
end
