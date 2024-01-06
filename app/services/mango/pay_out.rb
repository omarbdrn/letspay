# frozen_string_literal: true

module Mango
  class PayOut < Base

    def create(merchant)
      @merchant = merchant
      handle_result(MangoPay::PayOut::BankWire.create(pay_out_params))
    rescue MangoPay::ResponseError => ex
      handle_mango_error ex
    end

    def refresh(pay_out)
      response = MangoPay::PayOut.fetch(pay_out.mango_id)
      pay_out.mango_status      = response['Status']
      if pay_out.mango_status_changed?
        logger.send(pay_out.mango_status == 'SUCCEEDED' ? :info : :warn){ "payout.id=#{pay_out.id} payout.mango_id=#{pay_out.mango_id} refreshed=true new_status=#{pay_out.mango_status }" }
      end
      pay_out.mango_result_code = response['ResultCode']
      pay_out.failed_reason     = response['ResultMessage']
      pay_out.save
    rescue MangoPay::ResponseError => ex
      handle_mango_error ex
    end


    attr_reader :merchant

    private

    def pay_out_params
      {
        AuthorId: merchant.mango_id,
        DebitedFunds: {
          Currency: merchant.wallent_balance_currency,
          Amount: merchant.next_payout_amount_cents
        },
        Fees: {
          Currency: "USD",
          Amount: 0
        },
        BankAccountId: merchant.bank_account.mango_id,
        DebitedWalletId: merchant.mango_wallet_id,
       }
     end

    def handle_result(result)
      operation = ::PayOut.create_from_mango_params_and_merchant_id!(result, merchant.id)
      message = result['ResultMessage']
      if message.blank? || message == 'Success'
        logger.info { "payout.mango_id=#{operation.mango_id} merchant_id=#{merchant.id} created=true" }
        merchant.update_next_pay_out_date!
        operation
      else
        @error = message
        logger.error { "payout.mango_id=#{operation.mango_id} merchant_id=#{merchant.id} created=false reason=#{@error} params=#{request_params}" }
        operation.mark_as_failed @error
        false
      end
    end

  end
end
