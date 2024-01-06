# frozen_string_literal: true

module Mango
  class Transfer < Base

    def create(share)
      @share = share
      @purchase = share.purchase
      handle_result(MangoPay::Transfer.create(transfer_params))
    rescue MangoPay::ResponseError => ex
      handle_mango_error ex
    end

    attr_reader :share, :purchase

    private

    def transfer_params
      {
        AuthorId: ENV['LETSPAY_MANGO_USER_ID'],
        DebitedFunds: {
          Currency: purchase.amount_currency,
          Amount: purchase.partially_successful_mode ? purchase.pre_authorized_amount_cents : purchase.raw_amount_cents
        },
        Fees: {
          Currency: purchase.amount_currency,
          Amount: purchase.partially_successful_mode ? purchase.pre_authorized_commission_amount_cents : purchase.commission_amount_cents
        },
        DebitedWalletId: ENV['LETSPAY_MANGO_WALLET_ID'],
        CreditedWalletId: share.merchant.try(:mango_wallet_id)
      }
    end

    def handle_result(result)
      operation = ::Transfer.create_from_mango_params_and_purchase_id!(result, purchase.id)
      if result['ResultMessage'] == 'Success'
        logger.info { "Transfer with mango_id #{result['Id']} successfully created for purchase #{purchase.id}" }
        true
      else
        @error = result['ResultMessage']
        logger.error { "Error when trying to create the transfer related to the purchase #{purchase.id}.\nReason: #{@error}.\nUsed params: #{transfer_params}" }
        operation.mark_as_failed @error
        false
      end
    end

  end
end
