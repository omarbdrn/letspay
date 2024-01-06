module Transactions
  class ExportCsv

    def call(transactions)
      csv = "Customer reference, Date, Amount, Fees (VAT exc.), VAT on fees, Fees (VAT inc.), Credited funds \n"

      transactions.each do |transaction|
        csv << transaction['merchant_reference'].to_s + ", "                                                                 # Customer references
        csv << (Time.at(transaction['ExecutionDate']).localtime.strftime("%d/%m/%Y") rescue "") + ", "                       # Date
        csv << format_amount(transaction.dig('DebitedFunds','Amount'), transaction.dig('DebitedFunds','Currency')) + ", "    # Amount (VAT inc.)
        csv << transaction['fees_vat_excl'].to_s + ", "                                                                      # fees (VAT EXC.)
        csv << transaction['vat'].to_s + ", "                                                                                # VAT
        csv << format_amount(transaction.dig('Fees', 'Amount'), transaction.dig('Fees', 'Currency')) + ", "                  # Fees (VAT inc.)
        csv << format_amount(transaction.dig('CreditedFunds','Amount'), transaction.dig('CreditedFunds','Currency'))         # Credited Funds
        csv << "\n"                                                                                                          # linebreak
      end
      csv
    end

    private

    def format_amount(amount, currency)
      amount.blank? || currency.blank? ? "" : Money.new(amount, currency).cents.to_s
    end
  end
end
