module Payments
  module ManualPurchaseConfirmation
    class MerchantResponse

      def initialize(purchase_id)
        @purchase = Purchase.find(purchase_id)
      end

      def confirm
        @transfer = ::Payments::CreateTransfers.new
        transfer.call(purchase.leader_share)
        if transfer.success?
          purchase.update(state: :LEADER_PROCESSED)
          purchase.shares.each do |share|
            share.set_expiration!
            share.save
            ShareMailer.invitation(share.id).deliver_later unless share.leader?
          end
          if purchase.leader_share.single_share?
            ShareMailer.validation(purchase.leader_share.id).deliver_later
          else PurchaseMailer.validation(purchase.id).deliver_later
          end
          # Send ticket by mail to merchant_hash
          MerchantMailer.send_ticket(purchase.id).deliver_later
          # Trigger Webhook
          Webhooks::PaymentProcessedJob.perform_later(purchase.leader_share.id)
          # Update Purchase state
          PurchaseStateJob.perform_later(purchase.id)
        else
          Rollbar.error("Transfer from ManualPurchaseConfirmation failed: purchase_id=#{purchase.id} errors=#{transfer.errors}")
        end
        transfer.success?
      end

      def cancel
        Mango::Refund.new.refund_pay_in(purchase.leader_share.pay_in, 100) if purchase.leader_share.single_share?
        purchase.update(state: :CANCELLED)
      end

      def error_message
        transfer.try(:errors)
      end

      attr_reader :purchase, :transfer

    end
  end
end
