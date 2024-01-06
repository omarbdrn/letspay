# frozen_string_literal: true

namespace :maintenance do
  desc 'Refresh PayOuts'
  task refresh_pay_out: :environment do
    Payments::RefreshPayOuts.new.run
  end
end
