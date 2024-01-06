# frozen_string_literal: true

namespace :maintenance do
  desc 'Set an api_key to every payor_info'
  task set_payor_info_api_key: :environment do
    PayorInfo.where.not(email: [nil, ""]).find_each do |payor_info|
      payor_info.set_api_key
      payor_info.save!
    end
  end
end
