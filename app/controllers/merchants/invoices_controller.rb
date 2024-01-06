module Merchants
  class InvoicesController < ApplicationController
    include MerchantsConcern

    before_action :skip_policy_scope, only: [:index]
    before_action :set_date

    def index
      authorize(merchant, :show_transactions?)
      params[:page] = params[:page] ? params[:page].to_i : 1
      fetch_transactions(params[:page])
      @transactions = enrich_transactions
    end

    def export_transactions
      authorize(merchant, :export_transactions?)
      fetch_all_transactions
      @transactions = enrich_transactions
      csv = Transactions::ExportCsv.new.call(@transactions)
      LetsPay::Logger.new(self.class.name).info { "merchant=#{merchant.id} export_csv_transactions_count=#{@transactions.count}" }
      send_data csv, filename: "transactions-#{@date.month}-#{@date.year}-#{merchant.name}.csv"
    end

    private

    def fetch_transactions(page)
      service = Mango::Transaction.new(merchant)
      @transactions = service.fetch_transactions(@date, params[:page])
      @pages_count = service.total_pages
    end

    def fetch_all_transactions
      @transactions = Mango::Transaction.new(merchant).fetch_all_transactions(@date)
    end

    def enrich_transactions
      Transactions::BindPurchaseVat.new.call(@transactions)
    end

    def set_date
      if params.dig(:date, :year) && params.dig(:date, :month)
        @date = Date.new(params[:date][:year].to_i, params[:date][:month].to_i)
      else
        @date = Date.today
      end
    end
  end
end
