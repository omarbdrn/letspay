# frozen_string_literal: true

module Mango
  class SingleSharePayInReturn < Base

    def call(pay_in)
      @pay_in   = pay_in
      share     = pay_in.share
      purchase  = share.purchase

      if share.merchant.manual_purchase_confirmation_mode? && pay_in.mango_status == Mango::SUCCEEDED_OPERATION_STATUS
        purchase.update(state: :WAITING_MERCHANT_VALIDATION)

      elsif pay_in.mango_status == Mango::SUCCEEDED_OPERATION_STATUS
        # Send mail to leader
        ShareMailer.validation(share.id).deliver_later

        transfer = execute_transfer(share)
        if transfer.success?
          # Send ticket by mail to merchant_hash
          MerchantMailer.send_ticket(purchase.id).deliver_later
          # Trigger Webhook
          Webhooks::PaymentProcessedJob.perform_later(share.id)
          # Update Purchase state
          PurchaseStateJob.perform_later(purchase.id)
        else
          Rollbar.error("Transfer failed: purchase_id=#{purchase.id} errors=#{transfer.errors}")
          @error = { message: transfer.errors }
        end
      end

      self
    end

    def value
      pay_in
    end

    def error_message
      error[:message].to_s
    end

    private

    attr_reader :pay_in

    def execute_transfer(share)
      transfer = ::Payments::CreateTransfers.new
      transfer.call(share)
      transfer
    end
  end
end
