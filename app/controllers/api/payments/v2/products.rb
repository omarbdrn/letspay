# frozen_string_literal: true

module API
  module Payments
    module V2
      class Products < Grape::API
        include API::Payments::V2::Helpers

        namespace :purchases do
          route_param :purchase_id do
            namespace :products do

              desc 'Get the variable price for a product'
              params do
                requires :product_id, type: String, desc: 'ID of the product'
                requires :cart_amount_cents, type: Integer, desc: 'Code of the product'
              end
              post do
                purchase       = ::Purchase.find(params[:purchase_id])
                authorize purchase, :payment_api_update?
                product        = ::Product.find(params[:product_id])
                builder        = ::Payments::UpdateProduct.new
                product_update = builder.call(purchase, product, params[:cart_amount_cents])
                if product_update.success?
                  present product.reload
                else
                  present api_error(409, product_application.errors)
                end
              end

            end
          end
        end
      end
    end
  end
end
