# frozen_string_literal: true

namespace :maintenance do
  desc 'Cancel outdated purchases'
  task cancel_outdated_purchases: :environment do
    Payments::ManualPurchaseConfirmation::CancelOutdatedPurchases.new.run
  end
end
