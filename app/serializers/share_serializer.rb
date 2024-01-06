# frozen_string_literal: true
# == Schema Information
#
# Table name: shares
#
#  id                :uuid             not null, primary key
#  email             :string           not null
#  purchase_id       :uuid             not null
#  account_id        :integer
#  amount_cents      :integer          default(0), not null
#  amount_currency   :string           default("USD"), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  payor_info_id     :integer
#  expired_at        :datetime
#  reminded_at       :datetime
#  service_fee_cents :integer          default(0), not null
#

class ShareSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :payment_url, :operation

  has_one :operation
  has_one :purchase
  has_many :products

  def payment_url
    if object.leader?
      Rails.application.routes.url_helpers.payment_url(merchant_id: object.merchant.slug, purchase_id: object.purchase_id, host: Rails.configuration.app_host, api_key: object.api_key)
    else
      Rails.application.routes.url_helpers.payment_url(merchant_id: object.merchant.slug, purchase_id: object.purchase_id, share_id: object.id, host: Rails.configuration.app_host, api_key: object.api_key)
    end
  end
end
