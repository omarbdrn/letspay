# frozen_string_literal: true

module Payments
  class CreatePreAuthorizations

    def call(share, card_params)
      @share = share
      create_mango_user unless mango_user_is_present?
      if verify_purchase_status && mango_user_is_present? && add_new_card(card_params[:card_number], card_params[:card_expiration_date], card_params[:card_cvx])
        create_pre_authorization(amount: card_params[:installment_amount])
      end
      self
    end

    def success?
      pre_authorization_request.present? && pre_authorization_request.success?
    end

    def value
      operation
    end

    attr_reader :errors, :pre_authorization_request, :share, :operation

    private

    def verify_purchase_status
      unless share.purchase.INITIALIZED? || (share.purchase.LEADER_PROCESSED? && share.purchase.merchant_multicard_mode)
        @errors = 'The related purchase must be in INITIALIZED status to be configured'
        false
      end
      true
    end

    def mango_user_is_present?
      share.payor_info.related_mango_user_exist?
    end

    def create_mango_user
      request = Mango::NaturalUser.new
      request.create(share.payor_info)
      share.payor_info.reload
      @errors = request.error_message
      request.success?
    end

    def add_new_card(card_number, card_expiration_date, card_cvx)
      request = Mango::Card.new
      card_attrs = request.create(share.payor_info, card_number, card_expiration_date, card_cvx)
      if request.success?
        share.payor_info.add_card_from_attributes(card_attrs)
      else
        @errors = request.error_message
        false
      end
    end

    def create_pre_authorization(amount: nil)
      @pre_authorization_request = Mango::PreAuthorization.new
      @operation = pre_authorization_request.create(share: share, amount: amount)
      @errors = pre_authorization_request.error_message
      pre_authorization_request.success?
    end

  end
end
