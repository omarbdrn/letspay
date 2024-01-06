module Payments
  module ManualPurchaseConfirmation
    class CancelOutdatedPurchases

      def run
        ::Purchase.manual_confirmation_outdated.find_each do |purchase|
          ::Payments::ManualPurchaseConfirmation::MerchantResponse.new(purchase.id).cancel
        end
      end
    end
  end
end
