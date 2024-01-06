# frozen_string_literal: true

module Payments
  class CreateTransfers

    def call(share)
      @transfer = Mango::Transfer.new
      transfer.create(share)
      self
    end

    def success?
      transfer.success?
    end

    def errors
      transfer.error_message
    end

    private

    attr_reader :transfer
  end
end
