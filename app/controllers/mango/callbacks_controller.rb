# frozen_string_literal: true

module Mango
  class CallbacksController < ApplicationController

    before_action :skip_authorization

    def pre_authorization
      request = Mango::PreAuthorization.new
      if request.refresh(params[:preAuthorizationId])
        return_integration = Mango::PreAuthorizationReturn.new.call(params[:preAuthorizationId])

        # success as in 'We have successfully integrated Mango's return'
        message = return_integration.success? ? success_message('pre_auth', return_integration.value) : error_message(return_integration.error)

        logger_letspay(self.class.name).info { "new pre_auth integrated: preauth_id=#{return_integration.value.id} status=#{return_integration.value.mango_status}" }

        broadcast(message)
        head :ok
      else
        message = request.error_message
        Rollbar.error("Unmatched pre-authorization: preauth_mango_id=#{params[:preAuthorizationId]} message=#{message}")

        render json: message, status: 400
      end
    end

    def pay_in
      request = Mango::PayIn.new
      if request.refresh(params[:transactionId])
        pay_in  = ::PayIn.find_by_mango_id(params[:transactionId])

        if pay_in.share.single_share?
          return_integration = Mango::SingleSharePayInReturn.new.call(pay_in)
        elsif pay_in.share.merchant.multicard_mode?
          return_integration = Mango::MulticardPayInReturn.new.call(pay_in)
        else
          return_integration = Mango::PayInReturn.new.call(pay_in)
        end

        # Send information to front office
        if pay_in.share.single_share?
          message = return_integration.success? ? success_message('single_share_pay_in', return_integration.value) : error_message(return_integration.error)
        else
          message = return_integration.success? ? success_message('pay_in', return_integration.value) : error_message(return_integration.error)
        end
        
        broadcast(message)

        logger_letspay(self.class.name).info { "new payin integrated: pay_in_id=#{pay_in.id} status=#{pay_in.mango_status}" }

        head :ok
      else
        Rollbar.error("Unmatched Payin: payin_mango_id=#{params[:transactionId]} message=#{message}")

        message = request.error_message
        render json: message, status: 400
      end
    end

    private

    def success_message(type, request)
      { type: type, request: request, share: request.share }
    end

    def error_message(error)
      { type: 'error', message: error[:message], share: error[:preauth].share }
    end

    def broadcast(share:, type:, request: nil, message: nil)
      PaymentsChannel.broadcast_to share, type: type, request: request, message: message
    end
  end
end
