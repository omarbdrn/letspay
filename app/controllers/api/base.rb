# frozen_string_literal: true

module API
  class Base < Grape::API
    include API::Helpers

    content_type :json, 'application/json; charset=utf-8'
    default_error_formatter :json
    format :json
    formatter :json, Grape::Formatter::ActiveModelSerializers

    logger LetsPay::Logger.new('API')

    rescue_from ActiveRecord::RecordNotFound do |ex|
      logger.warn { "record not found model=#{ex.model} requested_id=#{ex.id}" }
      api_error 404
    end

    rescue_from ActiveRecord::RecordInvalid do |ex|
      logger.warn { "record invalid errors=#{ex.record.errors.details}" }
      api_error 409, ex.message
    end

    # rescue_from :all do |ex|
    #   api_error 500, "Internal Server Error: #{ex.message}"
    # end

    mount API::Merchants::Base
    mount API::Payments::Base
  end
end
