# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base

  def logger
    @logger ||= LetsPay::Logger.new(self.class.name)
  end

  private

  def check_merchant_response_status(response, share)
    if share.merchant.verify_webhook_response && !response.code.between?(200, 299)
      logger.error { "Merchant #{share.merchant.name} did not respond to webhook call with 200 share=#{share.id} response_code=#{response.code} response_body=#{response.body} " }
      raise ::Exceptions::MerchantDidNotRespondToWebhookWith200.new
    end
  end
end
