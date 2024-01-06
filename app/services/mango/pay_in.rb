# frozen_string_literal: true

module Mango
  class PayIn < Base

    def create(share)
      @share = share
      @request_params = pay_in_params
      handle_result(MangoPay::PayIn::Card::Direct.create(request_params))
    rescue MangoPay::ResponseError => ex
      handle_mango_error ex
    end

    def refresh(mango_pay_in_id)
      response = MangoPay::PayIn.fetch(mango_pay_in_id)
      pay_in = ::PayIn.find_by_mango_id(mango_pay_in_id)
      pay_in ? pay_in.update_from_mango_params(response) : false
    rescue MangoPay::ResponseError => ex
      handle_mango_error ex, extra: "letspay_pay_in_id=#{pay_in.try(:id)} mango_pay_in_id=#{mango_pay_in_id}"
    end

    def create_from_pre_authorization(pre_authorization_id)
      @pre_authorization = ::PreAuthorization.find(pre_authorization_id)
      @share = pre_authorization.share
      @request_params = pre_authorized_pay_in_params
      handle_result(MangoPay::PayIn::PreAuthorized::Direct.create(request_params))
    rescue MangoPay::ResponseError => ex
      handle_mango_error ex, extra: "letspay_preauth_id=#{pre_authorization_id} mango_preauth_id=#{pre_authorization.try(:mango_id)}"
    end

    def create_from_multicard_pre_authorization(pre_authorization_id)
      @pre_authorization = ::PreAuthorization.find(pre_authorization_id)
      @share = pre_authorization.share
      @request_params = multicard_pre_authorized_pay_in_params
      handle_result(MangoPay::PayIn::PreAuthorized::Direct.create(request_params))
    rescue MangoPay::ResponseError => ex
      handle_mango_error ex, extra: "letspay_preauth_id=#{pre_authorization_id} mango_preauth_id=#{pre_authorization.try(:mango_id)}"
    end

    def create_from_share_pre_authorization(pre_authorization_id)
      @pre_authorization = ::PreAuthorization.find(pre_authorization_id)
      @share = pre_authorization.share
      @request_params = share_pre_authorized_pay_in_params
      handle_result(MangoPay::PayIn::PreAuthorized::Direct.create(request_params))
    rescue MangoPay::ResponseError => ex
      handle_mango_error ex, extra: "letspay_preauth_id=#{pre_authorization_id} mango_preauth_id=#{pre_authorization.try(:mango_id)}"
    end

    def create_multicard_remaining_payin(purchase)
      @purchase = purchase
      @share = purchase.leader_share
      @request_params = multicard_remaining_payin_params
      handle_result(MangoPay::PayIn::Card::Direct.create(request_params))
    rescue MangoPay::ResponseError => ex
      handle_mango_error ex
    end

    attr_reader :share, :purchase, :pre_authorization, :request_params

    private

    def pay_in_params
      {
        AuthorId: share.payor_info.try(:mango_id),
        CreditedWalletId: ENV['LETSPAY_MANGO_WALLET_ID'],
        DebitedFunds: {
          Currency: share.amount_currency,
          Amount: share.amount_to_pay_cents
        },
        Fees: {
          Currency: share.amount_currency,
          Amount: 0
        },
        SecureModeReturnURL: Rails.application.routes.url_helpers.mango_callbacks_pay_in_url(host: Rails.configuration.app_host),
        CardId: share.payor_info.try(:default_mango_card_id),
        SecureMode: 'FORCE'
      }
    end

    def pre_authorized_pay_in_params
      {
        AuthorId: share.payor_info.try(:mango_id),
        CreditedWalletId: ENV['LETSPAY_MANGO_WALLET_ID'],
        DebitedFunds: {
          Currency: share.purchase.amount_currency,
          Amount: share.purchase.remaining_amount_cents
        },
        Fees: {
          Currency: share.amount_currency,
          Amount: 0
        },
        PreauthorizationId: pre_authorization.mango_id
      }
    end

    def share_pre_authorized_pay_in_params
      {
        AuthorId: share.payor_info.try(:mango_id),
        CreditedWalletId: ENV['LETSPAY_MANGO_WALLET_ID'],
        DebitedFunds: {
          Currency: share.amount_currency,
          Amount: share.amount_cents
        },
        Fees: {
          Currency: share.amount_currency,
          Amount: 0
        },
        PreauthorizationId: pre_authorization.mango_id
      }
    end

    def multicard_pre_authorized_pay_in_params
      {
        AuthorId: share.payor_info.try(:mango_id),
        CreditedWalletId: ENV['LETSPAY_MANGO_WALLET_ID'],
        DebitedFunds: {
          Currency: share.purchase.amount_currency,
          Amount: share.pre_authorization_amount_cents
        },
        Fees: {
          Currency: share.amount_currency,
          Amount: 0
        },
        PreauthorizationId: pre_authorization.mango_id
      }
    end

    def multicard_remaining_payin_params
      {
        AuthorId: share.payor_info.try(:mango_id),
        CreditedWalletId: ENV['LETSPAY_MANGO_WALLET_ID'],
        DebitedFunds: {
          Currency: purchase.amount_currency,
          Amount: purchase.multicard_remaining_amount_cents
        },
        Fees: {
          Currency: share.amount_currency,
          Amount: 0
        },
        SecureModeReturnURL: Rails.application.routes.url_helpers.mango_callbacks_pay_in_url(host: Rails.configuration.app_host),
        CardId: share.payor_info.try(:default_mango_card_id),
        SecureMode: 'FORCE'
      }
    end

    def handle_result(result)
      operation = ::PayIn.create_from_mango_params_and_share_id!(result, share.id)
      message = result['ResultMessage']
      if message.blank? || message == 'Success'
        logger.info { "PayIn with mango_id #{operation.mango_id} successfully created for share #{share.id}" }
        operation
      else
        @error = message
        logger.error { "Error when creating PayIn for share #{share.id}.\nReason: #{@error}\nUsed params: #{request_params}" }
        operation.mark_as_failed @error
        false
      end
    end

  end
end
