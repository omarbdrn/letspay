# frozen_string_literal: true

module API
  module Payments
    module V1
      class Discounts < Grape::API
        namespace :purchases do
          route_param :purchase_id do
            namespace :discounts do

              desc 'Apply a discount'
              params do
                requires :code, type: String, desc: 'Code of the discount'
              end
              post do
                purchase                = ::Purchase.find(params[:purchase_id])
                discount                = purchase.merchant.discounts.active.where('lower(discounts.code) = ?', params[:code].try(:downcase)).first
                builder                 = ::Payments::ApplyDiscount.new
                discount_application    = builder.call(purchase, discount)
                if discount_application.success?
                  present purchase.reload
                else
                  present api_error(409, discount_application.errors)
                end
              end

              desc 'Remove a discount'
              delete do
                purchase                = ::Purchase.find(params[:purchase_id])
                purchase.applied_discount.destroy if purchase.applied_discount.present?
                present purchase.reload
              end

            end
          end
        end
      end
    end
  end
end
