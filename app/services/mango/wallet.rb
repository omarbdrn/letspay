# frozen_string_literal: true

module Mango
  class Wallet < Base

    def create(merchant)
      @merchant = merchant
      response = MangoPay::Wallet.create(wallet_params)
      update_merchant_with_mango_id(response['Id'])
    rescue MangoPay::ResponseError => ex
      handle_mango_error ex
    end

    def show(merchant)
      MangoPay::Wallet.fetch(merchant.mango_wallet_id)
    end

    attr_reader :merchant

    private

    def wallet_params
      {
        Owners: [
          merchant.mango_id
        ],
        Description: "#{merchant.name} wallet",
        Currency: 'USD'
      }
    end

    def update_merchant_with_mango_id(mango_wallet_id)
      merchant.mango_wallet_id = mango_wallet_id
      logger.info { "Wallet with mango_id #{mango_wallet_id} successfully created for merchant #{merchant.id}" }
      merchant.save
    end

  end
end
