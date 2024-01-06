require 'sidekiq/web'
Rails.application.routes.draw do
  require 'sidekiq/web'

  get 'payment/:merchant_id/:purchase_id(/:share_id)', to: 'payment#cart_v2', as: :payment
  get 'payment/:merchant_id/:purchase_id',             to: 'payment#cart_v2', as: :multicard_remaining_shares_payment

  # get 'v2/payment/:merchant_id/:purchase_id(/:share_id)', to: 'payment#cart_v2', as: :payment_v2
  # get 'v2/payment/:merchant_id/:purchase_id',             to: 'payment#cart_v2', as: :multicard_remaining_shares_payment_v2

  devise_for :accounts, controllers: { passwords: 'devise/my_passwords' }

  mount API::Base => '/api'
  mount ForestLiana::Engine => '/forest'

  authenticate :account, lambda { |a| a.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  scope "(:locale)" do
    resources :merchants, only: [:index] do
      scope module: 'merchants' do
        resources :purchases, only: %i[index show create new]
        resources :shares, only: %i[execute_pre_auth]
        resources :invoices, only: %i[index export_transactions] do
          collection do
            get :export_transactions
          end
        end
        resources :pay_outs, only: %i[index]
        resource :configuration, only: %i[edit update]
        resource :api_key, only: %i[show]
        resource :bank_account, only: %i[create edit update]
        post 'purchases/:id/refund', to: 'purchases#refund', as: :purchase_refund
        post 'purchases/:id/confirm', to: 'purchases#confirm', as: :purchase_confirm
        post 'purchases/:id/cancel', to: 'purchases#cancel', as: :purchase_cancel
        post 'purchases/:id/confirm_multicard', to: 'purchases#confirm_multicard', as: :purchase_confirm_multicard
        post 'purchases/:id/cancel_multicard', to: 'purchases#cancel_multicard', as: :purchase_cancel_multicard
        post 'purchases/:id/execute_related_pre_auth', to: 'purchases#execute_related_pre_auth', as: :purchase_execute_related_pre_auth
        post 'shares/:id/execute_pre_auth', to: 'shares#execute_pre_auth', as: :share_execute_pre_auth
      end
    end
  end

  get 'merchants/dispatch', to: 'merchants#select_merchant', as: :merchants_dispatch

  namespace :mango do
    get 'callbacks/pre_authorization', to: 'callbacks#pre_authorization'
    get 'callbacks/pay_in',            to: 'callbacks#pay_in'
  end

  namespace :admin do
    root 'discount_purchases#index'
    resources :discount_purchases, only: [:index]
  end

  get :ping, to: 'ping#new'

  get '/.well-known/acme-challenge/:id', to: 'certbot#new'

  mount ActionCable.server => '/cable'

  root to: 'static#show'

end
