# frozen_string_literal: true

namespace :mango do
  desc 'Feed wallet LetsPay'

  task feed_letspay_wallet: :environment do
    return if Rails.env.production?
    10.times do
      share = FactoryGirl.create(:share, amount_cents: 4900)

      payor_info = FactoryGirl.create(:payor_info)
      Mango::NaturalUser.new.create(payor_info)
      request = Mango::Card.new
      response = request.create(payor_info, '4706750000000009', '1220', '123')
      payor_info.cards.create(response)
      share.payor_info = payor_info
      share.save

      response = MangoPay::PayIn::Card::Direct.create(
        AuthorId: share.payor_info.try(:mango_id),
        CreditedWalletId: ENV['LETSPAY_MANGO_WALLET_ID'],
        DebitedFunds: {
          Currency: share.amount_currency,
          Amount: share.amount_cents
        },
        Fees: {
          Currency: share.amount_currency,
          Amount: 0
        },
        SecureModeReturnURL: Rails.application.routes.url_helpers.mango_callbacks_pay_in_url(host: Rails.configuration.app_host),
        CardId: share.payor_info.try(:default_mango_card_id)
      )
      if response['Status'] == Mango::SUCCEEDED_OPERATION_STATUS
        puts '49$ added to letspay wallet'
      else
        puts 'Error when trying to add 49$ to letspay wallet'
      end
    end
  end
end
