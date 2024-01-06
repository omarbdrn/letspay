# frozen_string_literal: true

module Mango
  class Card < Base

    def create(payor_info, card_number, card_expiration_date, card_cvx)
      @payor_info = payor_info
      card_registration = Mango::CardRegistration.new.create(payor_info.mango_id)
      response = HTTParty.post(card_registration[:url], body: card_params(card_registration, card_number, card_expiration_date, card_cvx))
      handle_result(Mango::CardRegistration.new.update(card_registration[:id], response.body))
    rescue MangoPay::ResponseError => ex
      handle_mango_error ex
    end

    attr_reader :payor_info

    private

    def card_params(card_registration, card_number, card_expiration_date, card_cvx)
      {
        cardNumber: card_number,
        cardExpirationDate: card_expiration_date,
        cardCvx: card_cvx,
        accessKeyRef: card_registration[:access_key_ref],
        data: card_registration[:data]
      }
    end

    def handle_result(result)
      if result['ResultMessage'] == 'Success'
        logger.info { "Card with mango_id #{result['CardId']} successfully created for payor info with id #{payor_info.id}" }
        { mango_card_id: result['CardId'], card_type: result['CardType'], currency: result['Currency'] }
      else
        @error = result['ResultMessage']
        @logger.error { "Error when creating Card for payor info with id #{payor_info.id}.\nReason: #{@error}" }
        false
      end
    end

  end
end
