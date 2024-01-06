# frozen_string_literal: true

module Payments
  module Multicard
    class CreateManualMulticardPurchase

      Payload = Struct.new(:purchase_attrs, :leader_share_attrs, :payor_info_attrs, :products_attrs)

      def call(merchant, purchase_params, leader_params, notification_params)
        @merchant = merchant
        @purchase_params = purchase_params
        @leader_params = leader_params
        @notification_params = notification_params
        create_purchase if letspayer_shares.length > 0
        create_shares if create_purchase_success
        add_notification
        self
      end

      def letspayer_shares
        tmp_path = purchase_params[:file].path
        s = Roo::Excelx.new(tmp_path)
        full_sanitiser = Rails::Html::FullSanitizer.new
        s.parse(email: /email/i, amount_cents: /montant/i, clean: true).map { |h| { email: full_sanitiser.sanitize(h[:email]), amount_cents: (h[:amount_cents].to_f * 100).to_i}.stringify_keys }
      rescue Roo::HeaderRowNotFoundError => ex
        @errors = ex
        Rollbar.error("LetsPayer list upload errror: class=#{self.class.name} message=#{errors.message}")
        []
      end

      def success?
        create_purchase_success && create_shares_success
      end

      def value
        purchase
      end

      attr_reader :purchase_params, :leader_params, :notification_params, :errors, :purchase, :merchant, :payload, :create_shares_success, :create_purchase_success

      private

      def create_purchase
        @payload ||= Payload.new(purchase_attrs(purchase_amount), leader_share_attrs, payor_info_attrs, [])
        builder  = ::Merchants::CreatePurchase.new
        creation = builder.call(merchant: merchant, payload: payload)
        @purchase = creation.value
        @errors = creation.errors
        @create_purchase_success = creation.success?
      end

      def create_shares
        builder  = ::Payments::CreateShares.new
        creation = builder.call(purchase: purchase, share_attrs: letspayer_shares, leader_amount_cents: leader_share_amount_cents)
        @errors = creation.errors
        @create_shares_success = creation.success?
      end

      def add_notification
        account = ::Account.find_by_email(notification_params[:email])
        purchase.notifications.create!(account: account) if account.present?
      end

      def purchase_attrs(purchase_amount)
        {
          merchant_reference: purchase_params[:ref],
          title:              purchase_params[:title],
          callback_url:       purchase_params[:callback_url],
          raw_amount_cents:   purchase_amount,
          amount_cents:       purchase_amount,
          amount_currency:    purchase_params[:currency] || 'USD'
        }
      end

      def leader_share_attrs
        {
          email: leader_params[:email]
        }
      end

      def payor_info_attrs
        leader_params
      end

      def leader_share_amount_cents
        (purchase_params[:amount].to_f * 100).to_i
      end

      def purchase_amount
        leader_share_amount_cents + letspayer_shares.inject(0){ |sum, letspayer_share| sum + letspayer_share['amount_cents'] }
      end
    end
  end
end
