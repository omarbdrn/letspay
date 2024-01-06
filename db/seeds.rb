puts '=========== MERCHANTS ==========='
merchant = FactoryGirl.create(:merchant)
puts "#{merchant.name} created"
puts "\n"

puts '=========== ADMIN ==========='
unless admin = Account.find_by(email: 'admin@example.com')
  admin = FactoryGirl.create(:account, email: 'admin@example.com', password: 'changeme', password_confirmation: 'changeme', admin: true)
  admin.merchants << merchant
  admin.save
end
puts "Admin created ! Email: #{admin.email}, password: changeme"
puts "\n"

puts '=========== PURCHASES ==========='
FactoryGirl.create(:purchase_with_leader_share, merchant: merchant)
FactoryGirl.create(:purchase_with_shares, merchant: merchant)
puts '2 puchases created'
puts "\n"
