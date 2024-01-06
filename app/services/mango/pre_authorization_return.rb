# frozen_string_literal: true

module Mango
  class PreAuthorizationReturn < Base

    def call(preauth_mango_id)
      @preauth = ::PreAuthorization.find_by_mango_id(preauth_mango_id)
      share = preauth.traceable

      if share.merchant.multicard_mode? && preauth.mango_status == Mango::SUCCEEDED_OPERATION_STATUS
        if share.leader? && !share.merchant.manual_multicard_mode?
          purchase = share.purchase
          purchase.update(state: :LEADER_PROCESSED)
          purchase.letspayer_shares.each do |letspayer_share|
            ShareMailer.invitation_multicard(letspayer_share.id).deliver_later
          end
          PurchaseMailer.validation_multicard(purchase.id).deliver_later
        else
          ShareMailer.validation_multicard(share.id).deliver_later
          if preauth.manual_multicard_should_be_executed_now?
            MulticardPurchaseSucceededJob.perform_later(share.purchase.id)
          end
        end
      elsif share.merchant.manual_purchase_confirmation_mode? && preauth.mango_status == Mango::SUCCEEDED_OPERATION_STATUS
        purchase = share.purchase
        purchase.update(state: :WAITING_MERCHANT_VALIDATION)
        Webhooks::PaymentProcessedJob.perform_later(share.id)
      elsif share.leader? && preauth.mango_status == Mango::SUCCEEDED_OPERATION_STATUS
        purchase = share.purchase
        transfer = execute_transfer(share)
        if transfer.success?
          # Change Purchase state
          purchase.update(state: :LEADER_PROCESSED)

          # Send ticket by mail to merchant_hash
          MerchantMailer.send_ticket(purchase.id).deliver_later

          # Trigger Webhook
          Webhooks::PaymentProcessedJob.perform_later(share.id)

          # Send mails to letspayers
          purchase.letspayer_shares.each do |letspayer_share|
            ShareMailer.invitation(letspayer_share.id).deliver_later
          end
          PurchaseMailer.validation(purchase.id).deliver_later
        else
          Rollbar.error("Transfer failed: purchase_id=#{purchase.id} errors=#{transfer.errors}")
          preauth.destroy
          @error = { message: transfer.errors, preauth: preauth }
        end
      end
      self
    end

    def value
      preauth
    end

    def error_message
      error[:message].to_s
    end

    private

    attr_reader :preauth

    def execute_transfer(share)
      transfer = ::Payments::CreateTransfers.new
      transfer.call(share)
      transfer
    end
  end
end
