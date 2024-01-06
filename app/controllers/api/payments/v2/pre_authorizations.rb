# frozen_string_literal: true

module API
  module Payments
    module V2
      class PreAuthorizations < Grape::API
        include API::Payments::V2::Helpers

        namespace :pre_authorizations do
          desc 'Get a pre authorization'
          params do
            requires :pre_authorization_id, type: String, desc: 'ID of the pre authorization'
          end
          get ':pre_authorization_id' do
            pre_authorization = ::PreAuthorization.find(permitted_params[:pre_authorization_id])
            authorize pre_authorization.purchase, :payment_api_show?
            present pre_authorization
          end
        end

        namespace :shares do
          route_param :share_id do
            namespace :pre_authorizations do
              desc 'Create a new pre authorization'
              params do
                requires :card_number, type: String, desc: 'Card number'
                requires :card_expiration_date, type: String, desc: 'Card expiration date following this format MMYY'
                requires :card_cvx, type: String, desc: 'Card CVX'
                optional :optin, type: Boolean, desc: 'LetsPay optin'
                optional :installment_amount, type: Integer
              end
              post do
                share     = ::Share.find(params[:share_id])
                authorize share.purchase, :payment_api_show?
                share.payor_info.update(optin: !!permitted_params[:optin]) unless permitted_params[:optin].nil?
                builder   = ::Payments::CreatePreAuthorizations.new
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
