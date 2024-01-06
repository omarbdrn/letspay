# frozen_string_literal: true

module Merchants
  class PayOutsController < ApplicationController
    include MerchantsConcern

    # Pas de scope spécifique ici, un account avec accès à un merchant
    # a accès à la totalité de ces pay_outs
    before_action :skip_policy_scope, only: [:index]

    def index
      authorize(merchant, :show?)

      @pay_outs = merchant.pay_outs.page params[:page]
      respond_to do |format|
        format.html
      end
    end

  end
end
