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

class PayIn < Operation

  scope :successfull, -> { where(mango_status: Mango::SUCCEEDED_OPERATION_STATUS) }

  def self.create_from_mango_params_and_share_id!(mango_params, share_id)
    PayIn.create!(bind_mango_params_to_attributes(mango_params).merge(traceable_type: 'Share', traceable_id: share_id))
  end

  def max_refundable_amount_cents
    if share.leader?
      max_amount_cents = amount_cents - (shares_paid_by_leader_count * share.service_fee_cents)
    else
      max_amount_cents = amount_cents - share.service_fee_cents
    end
  end

  private

  def shares_paid_by_leader_count
    # Leader paid its own share and all unpaid shares
    if purchase.leader_share.paid?
      share.purchase.shares.select(&:unpaid?).count + 1
    else
      0
    end
  end

  def self.bind_mango_params_to_attributes(mango_params)
    {
      mango_id:           mango_params['Id'],
      mango_author_id:    mango_params['AuthorId'],
      mango_status:       mango_params['Status'],
      mango_result_code:  mango_params['ResultCode'],
      mango_card_id:      mango_params['CardId'],
      mango_redirect_url: mango_params['SecureModeRedirectURL'],
      amount_cents:       mango_params.dig('CreditedFunds', 'Amount'),
      amount_currency:    mango_params.dig('CreditedFunds', 'Currency')
    }
  end

end
