# frozen_string_literal: true

module Payments
  class CreateSinglePayIn

    def call(share, card_params)
      @share = share
      @payor_info = share.payor_info
      create_mango_user(payor_info) unless mango_user_is_present?
      if verify_purchase_status && mango_user_is_present? && add_new_card(payor_info, card_params[:card_number], card_params[:card_expiration_date], card_params[:card_cvx])
        create_pay_ins
      end
      self
    end

    def success?
      pay_in_request.present? && pay_in_request.success?
    end

    def value
      operation
    end

    attr_reader :errors, :pay_in_request, :share, :payor_info, :operation

    private

    def verify_purchase_status
      if share.purchase.INITIALIZED?
        true
      else
        @errors = 'The related purchase must be in INITIALIZED status to pay a share'
        false
      end
    end

    def mango_user_is_present?
      payor_info.related_mango_user_exist?
    end

    def create_mango_user(payor_info)
      request = Mango::NaturalUser.new
      request.create(payor_info)
      payor_info.reload
      @errors = request.error_message
      request.success?
    end

    def add_new_card(payor_info, card_number, card_expiration_date, card_cvx)
      request = Mango::Card.new
      card_attrs = request.create(payor_info, card_number, card_expiration_date, card_cvx)
      if request.success?
        payor_info.add_card_from_attributes(card_attrs)
      else
        @errors = request.error_message
        false
      end
    end

    def create_pay_ins
      @pay_in_request = Mango::PayIn.new
      @operation = @pay_in_request.create(share)
      @errors = @pay_in_request.error_message
      @pay_in_request.success?
    end

  end
end
