# frozen_string_literal: true

module Mango
  class MulticardPayInReturn < Base

    def call(pay_in)
      @pay_in   = pay_in
      share     = pay_in.share

      if pay_in.mango_status == Mango::SUCCEEDED_OPERATION_STATUS
        MulticardPurchaseSucceededJob.perform_later(share.purchase.id)
      end
      self
    end

    def value
      pay_in
    end

    attr_reader :error

    private

    attr_reader :pay_in
  end
end
