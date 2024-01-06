# frozen_string_literal: true

module Payments
  class UpdateProduct

    def initialize
      @errors = []
    end

    def call(purchase, product, cart_amount_cents)
      @purchase = purchase
      @product = product
      @cart_amount_cents = cart_amount_cents
      update_product! if product_can_be_updated?
      self
    end

    def success?
      product.amount_cents.positive? && product.valid?
    end

    def errors
      product.try(:errors)
    end

    private

    attr_reader :purchase, :product, :cart_amount_cents

    def update_product!
      product.update!(amount_cents: product.total_amount_cents(cart_amount_cents: cart_amount_cents))
    end

    def product_can_be_updated?
      product.variable_price && purchase.state == 'INITIALIZED'
    end
  end
end
