# frozen_string_literal: true

module Webhooks
  class PaymentFailedJob < ApplicationJob
    queue_as :webhooks
    include ActiveJob::Retry.new(strategy: :constant,
                               limit: (ENV['WEBHOOK_MAX_RETRY_COUNT'].try(:to_i) || 5),
                               delay: 1.minute,
                               retryable_exceptions: [::Exceptions::MerchantDidNotRespondToWebhookWith200])

    def perform(share_id)
      share = ::Share.find(share_id)
      check_merchant_response_status Webhooks::Merchants.new(share).payment_failed, share
    end
  end
end
