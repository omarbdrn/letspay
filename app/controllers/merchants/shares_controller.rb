# frozen_string_literal: true

module Merchants
  class SharesController < ApplicationController
    include MerchantsConcern

    # Pas de scope spécifique ici, un account avec accès à un merchant
    # a accès à la totalité de ces purchases
    before_action :skip_policy_scope

    def execute_pre_auth
      @share = Share.find(params[:id])
      authorize(merchant, :show?)
      pre_auth = @share.try(:pre_authorization)
      authorize(pre_auth, :force_execution?)
      Payments::ExecutePreAuthorizations.new.force_execution_for_share(@share)
      redirect_to merchant_purchase_path(@share.purchase.merchant, @share.purchase)
    end
  end
end
