module Transactions
  class BindPurchaseVat

    VAT_RATE = 20.0

    def call(transactions)
      transactions.each do |transaction|
        transfer = Transfer.find_by(mango_id: transaction["Id"].to_s)
        if transfer
          purchase = transfer.purchase
          transaction['merchant_reference'] = purchase.merchant_reference
          transaction['merchant_id']        = purchase.merchant_id
          transaction['purchase_id']        = purchase.id
        end
        transaction['fees_vat_excl']   = amount_without_vat(transaction["Fees"]["Amount"])
        transaction['vat']             = vat(transaction["Fees"]["Amount"])
      end
    end

    private

    def amount_without_vat(amount)
      (amount/((100 + VAT_RATE)/100.0)).round
    end

    def vat(amount)
      amount - amount_without_vat(amount)
    end
  end
end
