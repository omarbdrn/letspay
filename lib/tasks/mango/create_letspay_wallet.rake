# frozen_string_literal: true

namespace :mango do
  desc 'Create a wallet for LetsPay'
  task create_letspay_wallet: :environment do
    response = MangoPay::LegalUser.create(
      LegalPersonType: 'BUSINESS',
      Name: 'LetsPay',
      LegalRepresentativeBirthday: 1_883_016_00,
      LegalRepresentativeCountryOfResidence: 'US',
      LegalRepresentativeNationality: 'US',
      LegalRepresentativeFirstName: 'Admin',
      LegalRepresentativeLastName: 'LetsPay',
      Email: 'administrator@service.letspay.internal'
    )
    letspay_user_id = response['Id']
    response = MangoPay::Wallet.create(
      Owners: [letspay_user_id],
      Description: 'LetsPay wallet',
      Currency: 'USD'
    )
    puts "LetsPay user with id #{letspay_user_id} created"
    puts "LetsPay wallet with id #{response['Id']} created"
  end
end
