# frozen_string_literal: true

module Payments
  class CreateShares

    def call(purchase:, share_attrs:, leader_amount_cents: nil, leader_products: [])
      @purchase = purchase
      @service_fee_cents = purchase.merchant.service_fee_cents

      if leader_amount_cents.present?
        leader_share.assign_attributes(amount_cents: leader_amount_cents, service_fee_cents: service_fee_cents)
        @shares = build_shares(share_attrs).push(leader_share)
        if valid?
          delete_existing_shares
          shares.each(&:save)
        end
        if merchant.dispatchable_cart?
          update_products_by_shares(share_attrs)
          update_products_by_share(leader_share, leader_products)
        end
      else
        if old_share = purchase.shares.where(email: share_attrs.first['email']).first
          old_share.products.each(&:destroy)
          new_shares = update_shares(share_attrs)
        else new_shares = build_shares(share_attrs)
        end
        @shares = purchase.shares
        purchase.amount_cents = shares.sum(&:amount_cents)
        purchase.raw_amount_cents = purchase.amount_cents
        if valid?
          new_shares.each(&:save)
          if merchant.dispatchable_cart?
            build_products_and_update_by_shares(share_attrs)
          end
          if purchase.valid?
            purchase.save
          end
        end
      end
      self
    end

    def success?
      valid?
    end

    def value
      shares
    end

    def errors
      shares.map(&:errors)
    end

    private

    attr_reader :shares, :purchase, :service_fee_cents

    def build_share(share_attrs)
      share                   = purchase.shares.new(email: share_attrs['email'])
      share.payor_info        = PayorInfo.find_or_initialize_by(email: share_attrs['email'])
      share.email             = share_attrs['email']
      share.amount_cents      = share_attrs['amount_cents']
      share.service_fee_cents = service_fee_cents
      share.set_expiration!
      share
    end

    def update_share(share_attrs)
      share                   = purchase.shares.where(email: share_attrs['email']).first
      share.amount_cents      = share_attrs['amount_cents']
      share.service_fee_cents = service_fee_cents
      share.set_expiration!
      share
    end

    def build_shares(shares_attrs)
      shares_attrs.map { |share_attrs| build_share(share_attrs) }
    end

    def update_shares(shares_attrs)
      shares_attrs.map { |share_attrs| update_share(share_attrs) }
    end

    def valid?
      share_emails_are_unique && each_share_is_valid && sum_of_shares_amount_equals_purchase_amount
    end

    def each_share_is_valid
      shares.each { |share| return false unless share.valid? }
      true
    end

    def share_emails_are_unique
      if shares.pluck(:email).uniq.size == shares.size
        true
      else
        add_shares_error(:email, :unique, 'the email of each share must be unique')
      end
    end

    def sum_of_shares_amount_equals_purchase_amount
      if shares.map(&:amount_cents).inject(0) { |sum, amount| sum + amount } == purchase.amount_cents
        true
      else
        add_shares_error(:amount_cents, :incoherent_value, 'the sum of each share amount in cents must be equal to the related purchase amount in cents')
      end
    end

    def add_shares_error(field, error, message)
      shares.each do |share|
        share.errors.add(field, error, message: message)
      end
      false
    end

    def leader_share
      purchase.leader_share
    end

    def delete_existing_shares
      purchase.shares.includes(:share_products).each do |share|
        share.destroy if !share.leader? && share.persisted?
      end
    end

    def merchant
      purchase.merchant
    end

    def update_products_by_share(share, products_attrs)
      products_attrs.each do |product_attrs|
        product = Product.find(product_attrs['id'])
        product.share = share
        product.save!
      end
    end

    def update_products_by_shares(shares_attrs)
      shares_attrs.map { |share_attrs| update_products_by_share(shares.find { |share| share.email == share_attrs['email'] }, share_attrs['products']) }
    end

    def build_products_and_update_by_share(share_attrs)
      share_attrs['products'].each do |product_attrs|
        cart_product = Product.find(product_attrs['id'])
        product = purchase.products.create(merchant_reference: cart_product.merchant_reference, label: cart_product.label, amount_cents: cart_product.amount_cents, amount_currency: cart_product.amount_currency || 'USD', raw_amount_cents: cart_product.amount_cents, variable_price: cart_product.variable_price, price_bounds: cart_product.price_bounds, terms_url: cart_product.terms_url, description: cart_product.description)
        product.share = shares.find { |share| share.email == share_attrs['email'] }
        product.share_product.quantity = product_attrs['quantity']
        product.share_product.metadata = product_attrs['metadata'].to_json
        product.share_product.save!
        product.save!
      end
    end

    def build_products_and_update_by_shares(shares_attrs)
      shares_attrs.map { |share_attrs| build_products_and_update_by_share(share_attrs) }
    end
  end
end
