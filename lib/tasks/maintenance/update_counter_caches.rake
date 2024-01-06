# frozen_string_literal: true

namespace :maintenance do
  desc 'Updates counter caches in selected models'
  task update_counter_caches: :environment do
    Purchase.find_each do |purchase|
      Purchase.reset_counters(purchase.id, :shares)
    end
  end
end
