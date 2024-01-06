# frozen_string_literal: true

module API
  module Payments
    module V1
      class Shares < Grape::API

        namespace :shares do
          desc 'Get a share'
          params do
            requires :share_id, type: String, desc: 'ID of the share'
          end
          get ':share_id' do
            share = ::Share.find(permitted_params[:share_id])
            present share
          end
        end

        namespace :purchases do
          route_param :purchase_id do
            namespace :shares do
              desc 'Create new shares'
              params do
                optional :leader_amount_cents, type: Integer, desc: 'Amount of the leader share'
                optional :leader_products, type: Array do
                  requires :id, type: String
                end
                requires :letspayer_shares, type: Array do
                  requires :email, type: String, desc: 'E-mail'
                  requires :amount_cents, type: Integer, desc: 'Amount of the share in cents'
                  optional :first_name, type: String, desc: 'First name'
                  optional :last_name, type: String, desc: 'Last name'
                  optional :products, type: Array do
                    requires :id, type: String
                    optional :quantity, type: Integer
                  end
                end
              end
              post do
                purchase     = ::Purchase.find(params[:purchase_id])
                builder      = ::Payments::CreateShares.new
                creation     = builder.call(purchase: purchase, share_attrs: permitted_params[:letspayer_shares], leader_amount_cents: permitted_params[:leader_amount_cents], leader_products: permitted_params[:leader_products])
                if creation.success?
                  present creation.value
                else
                  present api_error(409, creation.errors)
                end
              end

              desc 'Update share'
              params do
                requires :id, type: String, desc: 'ID of the share'
                requires :payor_info_attributes, type: Hash do
                  optional :first_name, type: String, desc: 'First name'
                  optional :last_name, type: String, desc: 'Last name'
                  optional :timezone, type: String, desc: 'Timezone name'
                  optional :language, type: String, desc: 'Language'
                  optional :optin, type: Boolean, desc: 'Opt-in'
                  optional :merchant_reference, type: String, desc: 'Merchant reference'
                end
                optional :merchant_optin, type: Boolean, desc: 'Merchant Opt-in'
              end
              put ':id' do
                share = ::Share.find(permitted_params[:id])
                share.update!(permitted_params) # if share.email == permitted_params[:email]
              end
            end
          end
        end
      end
    end
  end
end
