# frozen_string_literal: true

module API
  module Payments
    module V2
      class Purchases < Grape::API
        include API::Payments::V2::Helpers

        namespace :purchases do

          desc 'Get a purchase'
          params do
            requires :purchase_id, type: String, desc: 'ID of the purchase'
          end
          get ':purchase_id' do
            purchase = ::Purchase.find(permitted_params[:purchase_id])
            authorize purchase, :payment_api_show?
            present purchase
          end

        end
      end
    end
  end
end
