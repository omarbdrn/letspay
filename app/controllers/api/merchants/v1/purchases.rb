# frozen_string_literal: true

module API
  module Merchants
    module V1
      class Purchases < Grape::API
        include API::Merchants::V1::Helpers

        namespace :purchases do
          desc 'Get a purchase'
          params do
            requires :purchase_id, type: String, desc: 'ID of the purchase'
          end
          get ':purchase_id' do
            purchase = ::Purchase.find(permitted_params[:purchase_id])
            authorize purchase, :show?

            logger.info { "endpoint=purchases method=GET merchant_id=#{current_merchant.id} purchase_id=#{purchase.id}" }

            present purchase
          end

          desc 'Create a new Purchase'
          params do
            requires :ref, type: String
            requires :title, type: String
            optional :subtitle, type: String
            optional :description, type: String
            optional :picture_url, type: String
            requires :amount, type: Integer
            optional :currency, type: String
            requires :callback_url, type: String
            requires :client, type: Hash do
              # requires :ref, type: String
              requires :last_name, type: String
              requires :first_name, type: String
              requires :email, type: String
            end
            optional :products, type: Array do
              requires :ref, type: String
              requires :label, type: String
              requires :amount, type: Integer
              optional :currency, type: String
            end
            optional :maximum_participants_number, type: Integer
            optional :partially_successful_mode, type: Boolean
            optional :cancel_url, type: String
            optional :timeout_seconds, type: Integer
          end
          post do
            new_purchase_payload = PayloadAdapter::Purchases::Post.new(permitted_params)
            builder = ::Merchants::CreatePurchase.new
            creation = builder.call(merchant: current_merchant, payload: new_purchase_payload)

            if creation.success?
              logger.info { "endpoint=purchases method=POST merchant_id=#{current_merchant.id} success=true purchase_id=#{creation.value.id}" }
              present creation.value
            else
              logger.info { "endpoint=purchases method=POST merchant_id=#{current_merchant.id} success=false errors=#{creation.errors.details}" }
              present api_error(409, creation.errors)
            end
          end
        end
      end
    end
  end
end
