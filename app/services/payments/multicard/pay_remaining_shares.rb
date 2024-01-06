# frozen_string_literal: true

module Payments
  module Multicard
    class PayRemainingShares

      def call(purchase, card_params)
        @purchase = purchase
        payor_info = purchase.leader_share.payor_info
        if add_new_card(payor_info, card_params[:card_number], card_params[:card_expiration_date], card_params[:card_cvx])
          create_multicard_remaining_payin
        end
        self
      end

      def success?
        pay_in_request.present? && pay_in_request.success?
      end

      def value
        operation
      end

      attr_reader :purchase, :errors, :pay_in_request, :operation

      private

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

      def create_multicard_remaining_payin
        @pay_in_request = Mango::PayIn.new
        @operation = @pay_in_request.create_multicard_remaining_payin(purchase)
        @errors = @pay_in_request.error_message
        @pay_in_request.success?
      end

    end
  end
end
