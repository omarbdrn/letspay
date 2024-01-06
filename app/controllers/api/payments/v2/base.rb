# frozen_string_literal: true

module API
  module Payments
    module V2
      class Base < Grape::API

        include API::Payments::V1::Helpers

        version 'v2'

        rescue_from Pundit::NotAuthorizedError do |ex|
          logger.warn { "unauthorized payor_info_id=#{current_payor_info.id} model=#{ex.record.class.name} query=#{ex.query} resource_id=#{ex.record.id}" }
          api_error 403
        end

        auth :payments_api_auth do |api_key|
          ::PayorInfo.where(api_key: api_key).exists?
        end

        mount API::Payments::V2::PayIns
        mount API::Payments::V2::PreAuthorizations
        mount API::Payments::V2::Purchases
        mount API::Payments::V2::Shares
        mount API::Payments::V2::Discounts
        mount API::Payments::V2::Products
      end
    end
  end
end
