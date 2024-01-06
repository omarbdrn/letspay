# frozen_string_literal: true

module Merchants
  module Purchases
    class IndexPresenter
      include ActionView::Helpers::NumberHelper

      delegate :total_count, to: :data

      attr_reader :filter

      def initialize(merchant_purchases: Purchase.none, filtered_purchases: Purchase.none, current_page: 0)
        @merchant_purchases = merchant_purchases
        @filtered_purchases = filtered_purchases
        @current_page = current_page
      end

      def total_amount
        # FIXME: Pas sûr de ce que ça donnera quand on commencera à mélanger les monnaies
        merchant_purchases.sum(&:amount)
      end

      def total_count
        merchant_purchases.size
      end

      def filtered_count
        filtered_purchases.size
      end

      def purchases
        filtered_purchases.order(created_at: :desc).page(current_page)
      end

      private

      attr_reader :merchant_purchases, :filtered_purchases, :current_page
    end
  end
end
