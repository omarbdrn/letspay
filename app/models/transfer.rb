# frozen_string_literal: true
# == Schema Information
#
# Table name: operations
#
#  id                           :integer          not null, primary key
#  failed_at                    :datetime
#  failed_reason                :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  type                         :string
#  mango_id                     :string
#  mango_author_id              :string
#  mango_status                 :string
#  mango_card_id                :string
#  mango_redirect_url           :string
#  pay_in_executed_at           :datetime
#  pay_in_mango_id              :string
#  amount_cents                 :integer          default(0)
#  amount_currency              :string           default("USD")
#  initial_transaction_mango_id :string
#  initial_transaction_type     :string
#  traceable_type               :string
#  traceable_id                 :uuid
#  mango_result_code            :string
#  merchant_id                  :integer
#

class Transfer < Operation

  def self.create_from_mango_params_and_purchase_id!(mango_params, purchase_id)
    Transfer.create!(bind_mango_params_to_attributes(mango_params).merge(traceable_type: 'Purchase', traceable_id: purchase_id, merchant_id: Purchase.find(purchase_id).merchant.id))
  end

  private

  def self.bind_mango_params_to_attributes(mango_params)
    {
      mango_id:           mango_params['Id'],
      mango_author_id:    mango_params['AuthorId'],
      mango_status:       mango_params['Status'],
      mango_result_code:  mango_params['ResultCode'],
      amount_cents:       mango_params.dig('CreditedFunds', 'Amount'),
      amount_currency:    mango_params.dig('CreditedFunds', 'Currency')
    }
  end
end
