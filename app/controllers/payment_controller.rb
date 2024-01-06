# frozen_string_literal: true

class PaymentController < ApplicationController

  layout false

  before_action :load_merchant, only: [:cart, :cart_v2]
  before_action :load_purchase, only: [:cart, :cart_v2]

  attr_reader :merchant, :purchase

  def cart
    skip_authorization

    # TODO : Add a real check on share_id
    @share = purchase.shares.where(id: params[:share_id]).first || purchase.leader_share
  end

  def cart_v2
    skip_authorization

    # TODO : Add a real check on share_id
    @share = purchase.shares.where(id: params[:share_id]).first || purchase.leader_share
  end

  private

  def load_merchant
    @merchant = Merchant.friendly.find(params[:merchant_id])
  end

  def load_purchase
    @purchase = Purchase.find(params[:purchase_id])
  end

end
