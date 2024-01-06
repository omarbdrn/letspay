# frozen_string_literal: true

module Mango
  class BankAccount < Base

    def create(bank_account)
      response = MangoPay::BankAccount.create(bank_account.merchant.mango_id, bank_account_params(bank_account))
      bank_account.mango_id = response['Id']
      logger.info { "bank_account.mango_id=#{bank_account.mango_id} merchant_id=#{bank_account.merchant.id} created=true" }
    rescue MangoPay::ResponseError => ex
      logger.error { "bank_account.mango_id=#{bank_account.mango_id} merchant_id=#{bank_account.merchant.id} created=false" }
      handle_mango_error ex
    end

    private

    def bank_account_params(bank_account)
      params = {
        Type: 'IBAN',
        IBAN: bank_account.iban,
        OwnerName: bank_account.owner_name,
        OwnerAddress: {
          AddressLine1: bank_account.owner_street,
          City: bank_account.owner_city,
          Region: bank_account.owner_region,
          PostalCode: bank_account.owner_zipcode,
          Country: bank_account.owner_country
        }
      }
      params['BIC'] = bank_account.bic if bank_account.bic.present?
      params
    end

  end
end
