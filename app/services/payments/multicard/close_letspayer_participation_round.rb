module Payments
  module Multicard
    class CloseLetsPayerParticipationRound

      def run_for_multicard
        ::Purchase.multicard_preauth_succeeded.find_each do |purchase|
          close_letspayer_participation_round(purchase) if purchase.should_close_letspayer_participation_round?
        end
      end

      def run_for_manual_multicard
        ::Purchase.MULTICARD_CONFIRMED.find_each do |purchase|
          close_letspayer_participation_round(purchase) if purchase.should_close_letspayer_participation_round?
        end
      end

      def close_letspayer_participation_round(purchase)
        if purchase.should_start_leader_last_chance_round?
          start_leader_last_chance_round(purchase)
        else
          MulticardPurchaseSucceededJob.perform_later(purchase.id)
        end
      end

      private

      def start_leader_last_chance_round(purchase)
        purchase.update(state: :MULTICARD_LETSPAYER_ROUND_TIMEOUT)
        PurchaseMailer.reminder_multicard(purchase.id).deliver_later
        purchase.shares.unreminded.reject(&:paid?).reject(&:pre_authorized?).select(&:is_manual_multicard?).each do |share|
          ShareMailer.reminder_multicard(share.id).deliver_later(wait: (rand * Payments::SEND_MAIL_TIME_RANGE_IN_SECONDS).to_i.seconds)
          share.reminded_at = Time.current
          share.save!
        end
      end
    end
  end
end
