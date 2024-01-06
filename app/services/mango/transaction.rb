# frozen_string_literal: true

module Mango
  class Transaction < Base

    TRANSACTIONS_PER_PAGE = 50.freeze

    def initialize(merchant)
      @merchant = merchant
      @wallet_id = merchant.mango_wallet_id
    end

    def fetch_transactions(date, page)
      begin
        MangoPay::Transaction.fetch(wallet_id, @filters = filters_params(date, page))
      rescue MangoPay::ResponseError => error
        LetsPay::Logger.new(self.class.name).warn { "merchant=#{merchant.id} fetch_transactions=false reason=#{error.inspect}" }
        Array.new
      end
    end

    def fetch_all_transactions(date)
      transactions = fetch_transactions(date, 1)
      (2..total_pages).to_a.each do |page_nb|
        transactions += fetch_transactions(date, page_nb)
      end
      transactions
    end

    def total_pages
      @filters['total_pages'] || 0
    end

    private

    attr_accessor :wallet_id, :merchant

    def filters_params(date, page)
      {
        page: page,
        per_page: TRANSACTIONS_PER_PAGE,
        AfterDate: (date.beginning_of_month.to_time.to_i),              # from first second of the month
        BeforeDate: (date.next_month.beginning_of_month.to_time.to_i),  # until first second of next month
        sort: "CreationDate:ASC",
        status: "SUCCEEDED",
        type: "TRANSFER"
      }
    end
  end
end
