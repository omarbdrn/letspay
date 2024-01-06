module Webhooks
  class Merchants
    def initialize(share)
      @share = share
      @merchant = share.merchant
      @logger = LetsPay::Logger.new('Webhooks')
    end

    def payment_processed
      post_to_merchant_with payment_processed_body
    end

    def payment_failed
      post_to_merchant_with payment_failed_body
    end

    def letspayer_contributed
      post_to_merchant_with letspayer_contributed_body
    end

    attr_reader :share, :merchant, :logger

    private

    def post_to_merchant_with(body)
      logger.info { "Webhook sent to url #{merchant.webhooks_url} with body : #{body}" }
      HTTParty.post(merchant.webhooks_url, options_for_post(body))
    end

    def options_for_post(body)
      body = add_signature(body)
      proxy = URI(ENV['QUOTAGUARDSTATIC_URL'])
      {
        http_proxyaddr: proxy.host,
        http_proxyport: proxy.port,
        http_proxyuser: proxy.user,
        http_proxypass: proxy.password,
        verify: false,
        body: body.to_json,
        headers:
        {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json'
        }
      }
    end

    def payment_processed_body
      {
        'triggerID': share.last_operation.id,
        'triggerDate': Time.zone.now.iso8601(3),
        'triggerName': 'paymentProcessed',
        'objects': {
          'purchaseId': share.purchase.id,
          'ref': share.purchase.merchant_reference
        }
      }
    end

    def payment_failed_body
      {
        'triggerID': share.last_operation.id,
        'triggerDate': Time.zone.now.iso8601(3),
        'triggerName': 'paymentFailed',
        'objects': {
          'purchaseId': share.purchase.id
        }
      }
    end

    def letspayer_contributed_body
      {
        'triggerID': share.last_operation.id,
        'triggerDate': Time.zone.now.iso8601(3),
        'triggerName': 'letspayerContributed',
        'objects': {
          'purchaseId': share.purchase.id,
          'shareId': share.id
        }
      }
    end

    def add_signature(body)
      body.merge(token: 'sha256_' + OpenSSL::HMAC.hexdigest('sha256', merchant.secret_token, order_and_concatenate(body)))
    end

    def order_and_concatenate(hash)
      final_string = hash.deep_dup
      final_string.map do |k, v|
        if v.is_a? Hash
          final_string[k] = v.sort.to_h.map { |key, value| "#{key}=#{value}" }.join('')
        end
      end
      final_string.sort.to_h.map { |k, v| "#{k}=#{v}" }.join('')
    end
  end
end
