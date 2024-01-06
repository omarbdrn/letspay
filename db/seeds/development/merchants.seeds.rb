puts '=========== MERCHANTS ==========='
m = FactoryGirl.create(:merchant)
puts "#{m.name} created !"
puts "\n"

puts '=========== PURCHASES ==========='
FactoryGirl.create(:purchase_with_leader_share)
FactoryGirl.create(:purchase_with_shares)
puts '2 puchases created !'
puts "\n"

puts '=========== DISCOUNTS ==========='
FactoryGirl.create(:discount, merchant: m)
FactoryGirl.create(:discount, merchant: m)
FactoryGirl.create(:discount, :percentage, merchant: m)
FactoryGirl.create(:discount, :percentage, merchant: m)
