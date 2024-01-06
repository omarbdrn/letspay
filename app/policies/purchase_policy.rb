# frozen_string_literal: true

class PurchasePolicy < ApplicationPolicy

  def payment_api_show?
    purchase = record
    purchase.payor_infos.include? payor_info
  end

  def payment_api_update?
    purchase = record
    purchase.leader_share.payor_info == payor_info
  end

  def confirm?
    purchase = record
    account && account.merchants.exists?(purchase.merchant.id) && purchase.merchant.manual_purchase_confirmation_mode? && purchase.state == 'WAITING_MERCHANT_VALIDATION' && (purchase.leader_share.pre_authorized? || purchase.leader_share.pay_in.present?)
  end

  def confirm_multicard?
    purchase = record
    account && account.merchants.exists?(purchase.merchant.id) && purchase.merchant.multicard_mode? && purchase.merchant.manual_multicard_mode? && purchase.state == 'INITIALIZED'
  end

  def refund?
    purchase = record
    account && account.merchants.exists?(purchase.merchant.id) && (purchase.state == "SUCCESSFUL") && purchase.transfer.present?
  end

  def partial_refund?
    purchase = record
    account && account.merchants.exists?(purchase.merchant.id) && (purchase.state == "SUCCESSFUL" || purchase.state == "PARTIALLY_REFUNDED") && purchase.transfer.present?
  end

  class Scope < Scope

    def resolve
      scope.where(merchant_id: account.id)
    end
  end
end
