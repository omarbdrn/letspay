# frozen_string_literal: true

module API
  module Payments
    module V2
      class PayIns < Grape::API
        include API::Payments::V2::Helpers
        
        namespace :purchases do
          route_param :purchase_id do
            namespace :multicard_pay_in do
              desc 'Multicard Pay In'
              params do
                requires :card_number, type: String, desc: 'Card number'
                requires :card_expiration_date, type: String, desc: 'Card expiration date following this format MMYY'
                requires :card_cvx, type: String, desc: 'Card CVX'
              end
              post do
                purchase                = ::Purchase.find(params[:purchase_id])
                authorize purchase, :payment_api_update?
                builder   = ::Payments::Multicard::PayRemainingShares.new
                creation  = builder.call(purchase, permitted_params)

                if creation.success?
                  present builder.value
                else
                  present api_error(409, creation.errors)
                end
              end
            end
          end
        end

        namespace :pay_ins do
          desc 'Get a pay on'
          params do
            requires :pay_in_id, type: String, desc: 'ID of the pre pay in'
          end
          get ':pay_in_id' do
            pay_in = ::PayIn.find(permitted_params[:pay_in_id])
            authorize pay_in.purchase, :payment_api_show?
            present pay_in
          end
        end

        namespace :shares do
          route_param :share_id do
            namespace :pay_ins do
              desc 'Create a new pay in'
              params do
                requires :card_number, type: String, desc: 'Card number'
                requires :card_expiration_date, type: String, desc: 'Card expiration date following this format MMYY'
                requires :card_cvx, type: String, desc: 'Card CVX'
              end
              post do
                share     = ::Share.find(params[:share_id])
                authorize share.purchase, :payment_api_show?
                builder   = ::Payments::CreatePayIns.new
                creation  = builder.call(share, permitted_params)
                if creation.success?
                  present creation.value
                else
                  present api_error(409, creation.errors)
                end
              end
            end
          end
        end

        namespace :shares do
          route_param :share_id do
            namespace :single_share_pay_in do
              desc 'Create PayIn for a single share purchase'
              params do
                requires :card_number, type: String, desc: 'Card number'
                requires :card_expiration_date, type: String, desc: 'Card expiration date following this format MMYY'
                requires :card_cvx, type: String, desc: 'Card CVX'
              end
              post do
                share     = ::Share.find(params[:share_id])
                authorize share.purchase, :payment_api_show?
                builder   = ::Payments::CreateSinglePayIn.new
                creation  = builder.call(share, permitted_params)
                if creation.success?
                  present creation.value
                else
                  present api_error(409, creation.errors)
                end
              end
            end
          end
        end
      end
    end
  end
end
