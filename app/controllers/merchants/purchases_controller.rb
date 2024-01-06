# frozen_string_literal: true

module Merchants
  class PurchasesController < ApplicationController
    include MerchantsConcern

    # Pas de scope spécifique ici, un account avec accès à un merchant
    # a accès à la totalité de ces purchases
    before_action :skip_policy_scope, only: [:index]

    def index
      authorize(merchant, :show?)

      @q = merchant.filtered_purchases(params.dig(:view, :filter)).send(scope_param).order(created_at: :desc).ransack(params[:q])
      @results = Merchants::Purchases::IndexPresenter.new(
        merchant_purchases: merchant.purchases.successful.includes(:leader_share).order(created_at: :desc),
        filtered_purchases: @q.result,
        current_page: params[:page]
      )

      respond_to do |format|
        format.html
      end
    end

    def show
      authorize(merchant, :show?)
      @purchase = merchant.purchases.find(params[:id])
    end

    def new
      authorize(merchant, :show?)
      @managers = merchant.managers
    end

    def create
      authorize(merchant, :show?)

      build = Payments::Multicard::CreateManualMulticardPurchase.new
      creation = build.call(merchant, purchase_params, leader_params, notification_params)
      if creation.success?
        @purchase = creation.value
        redirect_to merchant_purchase_path(merchant, @purchase)
        flash[:notice] = t('.purchase_and_shares_creation_successful')
      else
        redirect_to new_merchant_purchase_path(merchant)
        flash[:alert] = t('.purchase_and_shares_creation_failed')
      end
    end

    def refund
      @purchase = merchant.purchases.find(params[:id])
      authorize(merchant, :show?)
      if Payments::RefundPurchase.new.call(@purchase, params[:refund_percentage])
        flash[:notice] = t('.refund_successful')
      else
        flash[:alert] = t('.refund_failed')
      end
      redirect_to merchant_purchase_path(@purchase.merchant, @purchase)
    end

    def execute_related_pre_auth
      @purchase = merchant.purchases.find(params[:id])
      authorize(merchant, :show?)
      pre_auth = @purchase.try(:leader_share).try(:pre_authorization)
      authorize(pre_auth, :force_execution?)
      Payments::ExecutePreAuthorizations.new.force_execution_for_purchase(@purchase)
      redirect_to merchant_purchase_path(@purchase.merchant, @purchase)
    end

    def execute_share_pre_auth(share)
      @purchase = merchant.purchases.find(params[:id])
      authorize(merchant, :show?)
      pre_auth = share.try(:pre_authorization)
      authorize(pre_auth, :force_execution?)
      Payments::ExecutePreAuthorizations.new.force_execution_for_share(share)
      redirect_to merchant_purchase_path(@purchase.merchant, @purchase)
    end

    def confirm
      @purchase = merchant.purchases.find(params[:id])
      authorize(@purchase, :confirm?)

      if Payments::ManualPurchaseConfirmation::MerchantResponse.new(@purchase.id).confirm
        flash[:notice] = t('.confirm_successful')
      else
        flash[:alert] = t('.confirm_failed')
      end
      redirect_to merchant_purchase_path(@purchase.merchant, @purchase)
    end

    def cancel
      @purchase = merchant.purchases.find(params[:id])
      authorize(@purchase, :confirm?)

      if Payments::ManualPurchaseConfirmation::MerchantResponse.new(@purchase.id).cancel
        flash[:notice] = t('.cancel_successful')
      else
        flash[:alert] = t('.cancel_failed')
      end
      redirect_to merchant_purchase_path(@purchase.merchant, @purchase)
    end

    def confirm_multicard
      @purchase = merchant.purchases.find(params[:id])
      authorize(@purchase, :confirm_multicard?)

      if Payments::Multicard::MerchantResponse.new(@purchase.id).confirm(partially_successful: params[:partially_successful])
        flash[:notice] = t('.confirm_successful')
      else
        flash[:alert] = t('.confirm_failed')
      end
      redirect_to merchant_purchase_path(@purchase.merchant, @purchase)
    end

    def cancel_multicard
      @purchase = merchant.purchases.find(params[:id])
      authorize(@purchase, :confirm_multicard?)

      if Payments::Multicard::MerchantResponse.new(@purchase.id).cancel
        flash[:notice] = t('.cancel_successful')
      else
        flash[:alert] = t('.cancel_failed')
      end
      redirect_to merchant_purchase_path(@purchase.merchant, @purchase)
    end

    private

    def scope_param
      ['cancelled', 'successful', 'refunded', 'waiting_merchant_validation', 'all'].include?(params[:scope]) ? params[:scope] : 'successful'
    end

    def purchase_params
      required_params = [:ref, :title, :amount, :callback_url, :file]
      params.require(required_params)
      params.permit(:ref, :title, :subtitle, :description, :picture_url, :amount, :currency, :callback_url, :file)
    end

    def leader_params
      required_params = [:last_name, :first_name, :email]
      params.require(:client).require(required_params)
      params.require(:client).permit(:last_name, :first_name, :email)
    end

    def notification_params
      params.require(:account).permit(:email)
    end
  end
end
