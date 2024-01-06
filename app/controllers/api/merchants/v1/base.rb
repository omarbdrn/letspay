# frozen_string_literal: true

module API
  module Merchants
    module V1
      class Base < Grape::API

        logger LetsPay::Logger.new(%w(API Merchants V1))

        version 'v1'
        rescue_from Pundit::NotAuthorizedError do |ex|
          logger.warn { "unauthorized merchant_id=#{current_merchant.id} model=#{ex.record.class.name} query=#{ex.query} resource_id=#{ex.record.id}" }
          api_error 403
        end

        auth :merchants_api_auth do |api_key|
          ::Merchant.where(api_key: api_key).exists?
        end

        mount API::Merchants::V1::Purchases
      end
    end
  end
end
