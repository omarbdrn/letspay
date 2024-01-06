# frozen_string_literal: true

module Payments
  class ApplyDiscount

    def initialize
      @errors = []
    end

    def call(purchase, discount)
      @purchase = purchase
      @discount = discount
      apply_discount! if discount_can_be_applied?
      self
    end

    def success?
      discount_purchase.present? && discount_purchase.valid? && discount_purchase.persisted?
    end

    def errors
      discount_purchase.try(:errors)
    end

    private

    attr_reader :purchase, :discount, :discount_purchase

    def apply_discount!
      @discount_purchase = DiscountPurchase.create(purchase: purchase, discount: discount)
    end

    def discount_can_be_applied?
      discount.present? && !purchase.discount_applied && purchase.state == 'INITIALIZED'
    end



  end
end
