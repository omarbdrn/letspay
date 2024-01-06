# frozen_string_literal: true

module Merchants
  class CreatePurchase

    def call(merchant:, payload:)
      purchase = build_purchase(merchant, payload.purchase_attrs)
      build_leader_share(payload.leader_share_attrs)
      build_payor_info(payload.payor_info_attrs)
      build_products(payload.products_attrs)

      purchase.save if purchase.valid?
      self
    end

    def success?
      purchase.valid?
    end

    def value
      purchase
    end

    def errors
      purchase.errors
    end

    private

    attr_reader :purchase

    def build_purchase(merchant, purchase_attrs)
      @purchase = merchant.purchases.build(purchase_attrs)
    end

    def build_leader_share(leader_share_attrs)
      purchase.leader_share = purchase.shares.build(leader_share_attrs.merge(amount: purchase.amount))
      purchase.leader_share.set_expiration!
    end

    def build_payor_info(payor_info_attrs)
      payor_info = PayorInfo.find_or_create_by(email: payor_info_attrs[:email])
      payor_info.update_attributes(payor_info_attrs) if payor_info.first_name.blank?
      purchase.leader_share.payor_info = payor_info
    end

    def build_products(products_attrs)
      products_attrs.each do |product_attrs|
        purchase.products.build(product_attrs)
      end
    end
  end
end
