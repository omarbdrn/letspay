# frozen_string_literal: true

module Mango
  class PreAuthorization < Base

    def create(share:, amount: nil)
      @share = share
      handle_result(MangoPay::PreAuthorization.create(mango_pre_authorization_params(amount: amount)))
    rescue MangoPay::ResponseError => ex
      handle_mango_error ex
    end

    def refresh(mango_pre_authorization_id)
      response = MangoPay::PreAuthorization.fetch(mango_pre_authorization_id)
      pre_auth = ::PreAuthorization.find_by_mango_id(mango_pre_authorization_id)
      pre_auth ? pre_auth.update_from_mango_params(response) : false
    rescue MangoPay::ResponseError => ex
      handle_mango_error ex, extra: "letspay_preauth_id=#{pre_auth.try(:id)} mango_preauth_id=#{mango_pre_authorization_id}"
    end

    attr_reader :share

    private

    def mango_pre_authorization_params(amount: nil)
      {
        AuthorId: share.payor_info.try(:mango_id),
        DebitedFunds: {
          Currency: share.amount_currency,
          Amount: amount.present? ? amount : share.pre_authorization_amount_cents
        },
        SecureModeReturnURL: Rails.application.routes.url_helpers.mango_callbacks_pre_authorization_url(host: Rails.configuration.app_host),
        CardId: share.payor_info.try(:default_mango_card_id),
        SecureMode: 'FORCE'
      }
    end

    def handle_result(result)
      operation = ::PreAuthorization.create_from_mango_params_and_share_id!(result, share.id)
      result_message = result['ResultMessage']
      if result_message.blank? || result_message == 'Success'
        logger.info { "PreAuthorization with mango_id #{operation.mango_id} successfully created for share #{share.id}" }
        operation
      else
        @error = result_message
        logger.error { "Error when creating PreAuthorization for share #{share.id}.\nReason: #{@error}\nUsed params: #{mango_pre_authorization_params}" }
        logger.error { "RES #{result}" }
        operation.mark_as_failed @error
        false
      end
    end

  end
end
