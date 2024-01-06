# frozen_string_literal: true
# == Schema Information
#
# Table name: products
#
#  id                 :uuid             not null, primary key
#  merchant_reference :string
#  label              :string
#  amount_cents       :integer          default(0), not null
#  amount_currency    :string           default("USD"), not null
#  purchase_id        :uuid             not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  raw_amount_cents   :integer          default(0), not null
#

class ProductSerializer < ActiveModel::Serializer
  attribute :amount_cents, key: :amount
  attribute :amount_currency, key: :currency
  attribute :merchant_reference, key: :ref
  attribute :label
  attribute :letspayer_email
  attribute :id

  def letspayer_email
    object.try(:share).try(:email)
  end
end
