MangoPay.configure do |c|
  c.preproduction = !Rails.env.production?
  c.client_id = ENV['MANGO_CLIENT_ID']
  c.client_passphrase = ENV['MANGO_PASSPHRASE']
  c.log_file = File.join('log', 'mangopay.log')
end
