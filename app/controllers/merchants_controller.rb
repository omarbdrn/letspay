# frozen_string_literal: true

class MerchantsController < ApplicationController
  before_action :authenticate_account!
  before_action :skip_policy_scope, only: [:index]

  def index
    @merchants = current_account.merchants

    respond_to do |format|
      format.html do
        redirect_to merchants_dispatch_path
      end
    end
  end

  def select_merchant
    @merchants = current_account.merchants
    @hide_merchant_header = true
  end

end
