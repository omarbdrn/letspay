# frozen_string_literal: true

module Mango
  class CardRegistration < Base

    def create(mango_id)
      response = MangoPay::CardRegistration.create(
        UserId: mango_id,
        Currency: 'USD'
      )
      { id: response['Id'], access_key_ref: response['AccessKey'], data: response['PreregistrationData'], url: response['CardRegistrationURL'] }
    end

    def update(id, data)
      MangoPay::CardRegistration.update(id, RegistrationData: data)
    end

  end
end
