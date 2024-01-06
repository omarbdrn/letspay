# frozen_string_literal: true

module API
  module Payments
    module V1
      class Base < Grape::API

        include API::Payments::V1::Helpers

        version 'v1'

        mount API::Payments::V1::PayIns
        mount API::Payments::V1::PreAuthorizations
        mount API::Payments::V1::Purchases
        mount API::Payments::V1::Shares
        mount API::Payments::V1::Discounts
        mount API::Payments::V1::Products
      end
    end
  end
end
