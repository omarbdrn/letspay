# frozen_string_literal: true

module Merchants
  class DemoGenerator

    attr_reader :purchase, :merchant

    def initialize(merchant:, purchase:)
      @merchant = merchant
      @purchase = purchase
    end

    def url
      "https://demo.service.letspay.internal/?s=#{merchant_hash}&p=#{purchase_hash}&u=#{leader_hash}#/cart"
    end

    private

    def merchant_hash
      Base64.strict_encode64({
        name: merchant.name,
        pictureUrl: merchant.picture_url,
        mainUrl: merchant.site_url
      }.to_json)
    end

    def purchase_hash
      Base64.strict_encode64({
        name: purchase.title,
        subtitle: purchase.subtitle,
        pictureUrl: 'https://letspay-demo.netlify.com/logo_blue.png',
        amount: purchase.amount_cents
      }.to_json)
    end

    def leader_hash
      share = purchase.leader_share

      Base64.strict_encode64({
        name: share.payor_info.try(:full_name),
        email: share.email,
        leader: true,
        dirtyAmount: false,
        amount: purchase.amount_cents
      }.to_json)
    end

  end
end
