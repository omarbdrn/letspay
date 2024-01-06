# frozen_string_literal: true
# == Schema Information
#
# Table name: purchases
#
#  id                          :uuid             not null, primary key
#  title                       :string           not null
#  callback_url                :string           not null
#  merchant_reference          :string           not null
#  subtitle                    :string
#  description                 :string
#  picture_url                 :string
#  comment                     :string
#  merchant_id                 :integer          not null
#  amount_cents                :integer          default(0), not null
#  amount_currency             :string           default("USD"), not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  leader_share_id             :uuid
#  state                       :integer          default("INITIALIZED"), not null
#  shares_count                :integer          default(0), not null
#  raw_amount_cents            :integer          default(0), not null
#  maximum_participants_number :integer
#

class PurchaseSerializer < ActiveModel::Serializer

  belongs_to :leader_share, key: :client, class_name: 'Share', serializer: ShareSerializer
  has_many :products, each_serializer: ProductSerializer

  attribute :raw_amount_cents, key: :amount
  attribute :amount_currency, key: :currency
  attribute :merchant_reference, key: :ref

  attributes  :id, :title, :subtitle,
              :description, :picture_url,
              :products, :state,
              :callback_url, :payment_url,
              :maximum_participants_number,
              :merchant_multicard_mode,
              :letspayers_emails, :discount_applied, :amount_cents, :discount_cents, :raw_amount_cents, :multicard_remaining_amount_cents, :discount_code_with_amount_or_percentage


  def letspayers_emails
    object.state == 'SUCCESSFUL' ? object.shares.select { |share| share.payor_info.optin }.pluck(:email) : []
  end

  def payment_url
    Rails.application.routes.url_helpers.payment_url(merchant_id: object.merchant.slug, purchase_id: object.id, host: Rails.configuration.app_host, api_key: object.leader_share.payor_info.api_key)
  end
end
