module Payments
  module Multicard
    class CloseLeaderLastChanceRound

      def run
        ::Purchase.multicard_letspayer_round_timeout.find_each do |purchase|
          close_leader_last_chance_round(purchase) if purchase.leader_share.multicard_leader_last_chance_round_expired?
        end
      end

      def close_leader_last_chance_round(purchase)
        if purchase.partially_successful_mode? && purchase.all_pre_authorized_shares_count.positive?
          purchase.update(state: :PARTIALLY_SUCCESSFUL)
        else
          purchase.update(state: :FAILED)
          purchase.shares.each do |share|
            ShareMailer.multicard_failed(share.id).deliver_later(wait: (rand * Payments::SEND_MAIL_TIME_RANGE_IN_SECONDS).to_i.seconds)
          end
        end
      end
    end
  end
end
