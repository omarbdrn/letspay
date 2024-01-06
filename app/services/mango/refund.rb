# frozen_string_literal: true

module Mango
  class Refund < Base

    def refund_pay_in(pay_in, refund_percentage = 100)
      result = MangoPay::PayIn.refund(pay_in.mango_id, refund_pay_in_params(refund_percentage, pay_in))
      handle_pay_in_result(result, pay_in)
    rescue MangoPay::ResponseError => ex
      handle_mango_error ex
    end

    def refund_transfer(transfer, refund_percentage = 100)
      if refund_percentage.blank? || refund_percentage == 100
        result = MangoPay::Transfer.refund(transfer.mango_id, full_refund_transfer_params(transfer))
        handle_transfer_result(result, transfer)
      else
        result = MangoPay::Transfer.create(partial_refund_transfer_params(refund_percentage, transfer))
        handle_transfer_result(result, transfer)
      end
    rescue MangoPay::ResponseError => ex
      handle_mango_error ex
    end

    private

    def refund_pay_in_params(refund_percentage, pay_in)
      {
        AuthorId: pay_in.mango_author_id,
        DebitedFunds: {
          Currency: pay_in.amount_currency,
          Amount: pay_in.max_refundable_amount_cents * refund_percentage / 100
        },
        Fees: {
          Currency: pay_in.amount_currency,
          Amount: 0
        }
      }
    end

    def full_refund_transfer_params(transfer)
      {
        AuthorId: transfer.mango_author_id
      }
    end

    def partial_refund_transfer_params(refund_percentage, transfer)
      purchase = transfer.purchase
      {
        AuthorId: purchase.merchant.try(:mango_id),
        DebitedFunds: {
          Currency: purchase.amount_currency,
          Amount: (purchase.amount_cents - purchase.commission_amount_cents) * refund_percentage / 100
        },
        Fees: {
          Currency: purchase.amount_currency,
          Amount: 0
        },
        DebitedWalletId: purchase.merchant.mango_wallet_id,
        CreditedWalletId: ENV['LETSPAY_MANGO_WALLET_ID']
      }
    end

    def handle_pay_in_result(result, pay_in)
      operation = ::Refund.create_from_mango_params_and_share_id!(result, pay_in.traceable_id)
      if result['ResultMessage'] == 'Success'
        logger.info { "Refund with mango_id #{result['Id']} successfully created for pay_in with mango id #{pay_in.mango_id}" }
        true
      else
        @error = result['ResultMessage']
        logger.error { "Error when trying to refund the pay_in with mango id #{pay_in.id}.\nReason: #{@error}." }
        operation.mark_as_failed @error
        false
      end
    end

    def handle_transfer_result(result, transfer)
      @result = result
      operation = ::Refund.create_from_mango_params_and_purchase_id!(result, transfer.purchase.id)
      if result['ResultMessage'] == 'Success'
        logger.info { "Refund with mango_id #{result['Id']} successfully created for transfer with mango id #{transfer.mango_id}" }
        true
      else
        @error = result['ResultMessage']
        logger.error { "Error when trying to refund the transfer with mango id #{transfer.id}.\nReason: #{@error}." }
        operation.mark_as_failed @error
        false
      end
    end


  end
end
