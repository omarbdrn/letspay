module Payments
  module Multicard
    class MerchantResponse

      def initialize(purchase_id)
        @purchase = Purchase.find(purchase_id)
      end

      def confirm(partially_successful: false)
        if partially_successful
          purchase.partially_successful_mode = true
        else
          purchase.state = 'MULTICARD_CONFIRMED'
        end
        purchase.multicard_confirmed_executed_at = Time.zone.now
        purchase.save
        purchase.shares.each do |share|
          share.set_expiration!
          share.save
          ShareMailer.invitation_multicard(share.id).deliver_later(wait: (rand * Payments::SEND_MAIL_TIME_RANGE_IN_SECONDS).to_i.seconds)
        end
        PurchaseMailer.validation_multicard(purchase.id).deliver_later
      end

      def cancel
        purchase.update(state: :CANCELLED)
      end

      attr_reader :purchase

    end
  end
end
