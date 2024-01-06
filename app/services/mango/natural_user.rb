# frozen_string_literal: true

module Mango
  class NaturalUser < Base

    def create(payor_info)
      response = MangoPay::NaturalUser.create(natural_user_params(payor_info))
      payor_info.mango_id = response['Id']
      logger.info { "Natural user with mango_id #{payor_info.mango_id} successfully created for payor_info id: #{payor_info.id}" }
      payor_info.save
    rescue MangoPay::ResponseError => ex
      handle_mango_error ex
    end

    private

    def natural_user_params(payor_info)
      {
        FirstName: payor_info.first_name || 'John',
        LastName: payor_info.last_name || 'Doe',
        Birthday:  1_363_596_631,
        Nationality: 'US',
        CountryOfResidence: 'US',
        Email: payor_info.email
      }
    end

  end
end
