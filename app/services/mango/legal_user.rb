# frozen_string_literal: true

module Mango
  class LegalUser < Base

    def create(merchant)
      response = MangoPay::LegalUser.create(legal_user_params(merchant))
      merchant.mango_id = response['Id']
      logger.info { "Legal user with mango_id #{merchant.mango_id} successfully created for merchant #{merchant.id}" }
      merchant.save
    rescue MangoPay::ResponseError => ex
      handle_mango_error ex
    end

    private

    def legal_user_params(merchant)
      {
        LegalPersonType: 'BUSINESS',
        Name: merchant.name,
        LegalRepresentativeBirthday: 1_463_496_101,
        LegalRepresentativeCountryOfResidence: 'US',
        LegalRepresentativeNationality: 'US',
        LegalRepresentativeFirstName: 'John',
        LegalRepresentativeLastName: 'Doe',
        Email: 'john@doe.com'
      }
    end

  end
end
