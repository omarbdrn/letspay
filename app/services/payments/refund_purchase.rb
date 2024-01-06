# frozen_string_literal: true

module Payments
  class RefundPurchase

    def call(purchase, refund_percentage = 100)
      @purchase = purchase
      @refund_percentage = refund_percentage.to_i
      if purchase.refundable? && consistent_refund_percentage?
        refund_letspayer_pay_ins
        refund_transfer
        purchase.reload.mark_as_refunded!
        true
      else
        LetsPay::Logger.new('RefundPurchase').warn { "merchant_name=#{purchase.merchant.name} merchant_id=#{purchase.merchant.id} refund=false purchase_id=#{purchase.id} current_balance=#{purchase.merchant.wallet_balance_amount}" }
        false
      end
    end

    def refund_letspayer_pay_ins
      shares = purchase.shares.select{ |share| share.paid? }
      shares.each { |share| Mango::Refund.new.refund_pay_in(share.pay_in, refund_percentage)}
    end

    def refund_transfer
      Mango::Refund.new.refund_transfer(purchase.transfer, refund_percentage)
    end

    private

    def consistent_refund_percentage?
      purchase.max_refund_percent >= refund_percentage && refund_percentage > 0
    end

    attr_reader :purchase, :refund_percentage

  end
end
