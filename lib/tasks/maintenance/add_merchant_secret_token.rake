# frozen_string_literal: true

namespace :maintenance do
  desc 'Set an secret_token to every merchant'
  task set_merchant_secret_token: :environment do
    Merchant.find_each do |merchant|
      merchant.webhooks_url = 'https://example.com' unless merchant.webhooks_url.present?
      merchant.secret_token = SecureRandom.hex(Merchant::SECRET_TOKEN_LENGTH)
      merchant.save!
    end
  end
end
