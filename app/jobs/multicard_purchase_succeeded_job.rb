# frozen_string_literal: true

class MulticardPurchaseSucceededJob < ApplicationJob
  queue_as :default

  def perform(purchase_id)
    purchase = ::Purchase.find(purchase_id)

    execute_every_pre_authorization(purchase)

    total_paid = purchase.successfull_pay_ins.sum(&:amount_cents)

    if total_paid >= purchase.amount_cents
      if purchase.state == 'MULTICARD_LETSPAYER_ROUND_TIMEOUT' && !purchase.merchant_manual_multicard_mode
        PurchaseMailer.leader_confirmation_multicard(purchase.id).deliver_later
      else
        PurchaseMailer.confirmation_multicard(purchase.id).deliver_later
      end
      purchase.update(state: :SUCCESSFUL)
      purchase.letspayer_shares.select(&:unpaid?).each do |share|
        ShareMailer.leader_paid_for_you(share.id).deliver_later
      end
      purchase.shares.select(&:is_manual_multicard?).each do |share|
        ShareMailer.manual_multicard_succeeded(share.id).deliver_later
      end
      transfer = execute_transfer(purchase.leader_share)
      if transfer.success?
        # Send ticket by mail to merchant_hash
        MerchantMailer.send_ticket(purchase.id).deliver_later
        # Trigger Webhook
        Webhooks::PaymentProcessedJob.perform_later(purchase.leader_share.id)
      else
        Rollbar.error("Transfer failed: purchase_id=#{purchase.id} errors=#{transfer.errors}")
      end
    elsif purchase.partially_successful_mode? && purchase.PARTIALLY_SUCCESSFUL?
      purchase.update(state: :SUCCESSFUL)
      transfer = execute_transfer(purchase.leader_share)
      unless transfer.success?
        Rollbar.error("Transfer failed: purchase_id=#{purchase.id} errors=#{transfer.errors}")
      end
    end
    logger.info { "MulticardPurchaseSucceededJob run: total_paid=#{total_paid} amount=#{purchase.amount_cents} new state=#{purchase.state}" }
  end

  private

  def execute_every_pre_authorization(purchase)
    purchase.shares.includes(:pre_authorization).select(&:pre_authorized?).each do |share|
      pre_auth = share.pre_authorization
      request = ::Mango::PayIn.new
      operation = request.create_from_multicard_pre_authorization(pre_auth.id)
      if request.success? && operation.mango_status == Mango::SUCCEEDED_OPERATION_STATUS
        pre_auth.pay_in_executed_at = Time.zone.now
        pre_auth.pay_in_mango_id = operation.id
        pre_auth.save
      else
        purchase.update(state: :MULTICARD_ERROR)
        Rollbar.error("Unable to execute pre-authorization in multicard purchase: purchase_id=#{purchase.id} preauth_id=#{pre_auth.id} error=#{request.error_message}")
        return false
      end
    end
  end

  def execute_transfer(share)
    transfer = ::Payments::CreateTransfers.new
    transfer.call(share)
    transfer
  end
end
