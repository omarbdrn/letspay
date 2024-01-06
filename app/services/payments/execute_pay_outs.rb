module Payments
  class ExecutePayOuts

    def run
      ::Merchant.find_each do |merchant|
        if merchant.should_receive_payout_now?
          execute_pay_out_for(merchant)
        else
          letspay_logger.info {
            "operation=payout_non_executed
             merchant_id=#{merchant.id}
             bank_account_present=#{merchant.bank_account.present?}
             bank_account_valid=#{merchant.bank_account.try(:mango_valid?)}
             wallet_balance_is_not_empty=#{merchant.wallet_balance_is_not_empty?}
             payout_is_past_due=#{merchant.payout_is_past_due?}
             last_payout_time=#{merchant.last_payout_time}
             next_pay_out_date=#{merchant.next_pay_out_date}"
          }
        end
      end
    end

    private

    def execute_pay_out_for(merchant)
      related_transfers_ids = merchant.transfers_between_last_payout_and_yesterday.ids
      request = ::Mango::PayOut.new
      operation = request.create(merchant)
      letspay_logger.info { "payout.mango_id=#{operation.mango_id} merchant_id=#{merchant.id} operation=execute_payout" }
      MerchantMailer.payout_summary(merchant.id, related_transfers_ids).deliver_later if request.success?
    end

    def letspay_logger
      @letspay_logger ||= LetsPay::Logger.new(self.class.name)
    end

  end
end
