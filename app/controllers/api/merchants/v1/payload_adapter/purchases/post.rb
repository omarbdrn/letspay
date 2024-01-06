# frozen_string_literal: true

module API
  module Merchants
    module V1
      module PayloadAdapter
        module Purchases
          class Post

            EXCLUDED_PURCHASE_KEYS = %i(ref client amount products currency).freeze

            ProductAdapter = Struct.new(:payload) do
              EXCLUDED_PRODUCT_KEYS = %i(ref amount currency).freeze

              def adapt
                payload
                  .merge(merchant_reference: payload[:ref], amount_cents: payload[:amount], amount_currency: payload[:currency] || 'USD', raw_amount_cents: payload[:amount])
                  .reject { |key, _| EXCLUDED_PRODUCT_KEYS.include? key.to_sym }
              end
            end

            def initialize(payload)
              @payload = payload.with_indifferent_access
            end

            def purchase_attrs
              @attrs ||= payload.merge(overwrite).reject { |key, _| EXCLUDED_PURCHASE_KEYS.include? key.to_sym }
            end

            def leader_share_attrs
              @leader_hash ||= { email: payload.dig(:client, :email) }
            end

            def payor_info_attrs
              @payor_info_hash ||= payload.fetch(:client, {})
            end

            def products_attrs
              @products_attrs ||= payload.fetch(:products, []).map do |product_attrs|
                ProductAdapter.new(product_attrs).adapt
              end
            end

            private

            attr_reader :payload

            def overwrite
              {
                merchant_reference:  payload[:ref],
                raw_amount_cents:    payload[:amount],
                amount_cents:        payload[:amount],
                amount_currency:     payload[:currency] || 'USD',
                payment_api_version: 'v2'
              }
            end
          end
        end
      end
    end
  end
end
