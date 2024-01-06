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

class Operation < ApplicationRecord
  belongs_to :traceable, polymorphic: true, optional: true
  belongs_to :merchant, optional: true
  validates :mango_id, presence: true

  scope :successful, -> { where(mango_status: Mango::SUCCEEDED_OPERATION_STATUS) }
  scope :failed, -> { where.not(mango_status: Mango::SUCCEEDED_OPERATION_STATUS) }

  monetize :amount_cents, allow_nil: true

  def purchase
    traceable_type == "Purchase" ? traceable : traceable.try(:purchase)
  end

  def share
    traceable if traceable_type == "Share"
  end

  def share=(share)
    self.traceable = share
  end

  def update_from_mango_params(mango_params)
    update!(Operation.bind_mango_params_to_attributes(mango_params))
  end

  def mark_as_failed(reason)
    self.failed_at = Time.zone.now
    self.failed_reason = reason
    save!
  end

  private

  # TODO: Use https://github.com/ismasan/hash_mapper instead
  def self.bind_mango_params_to_attributes(mango_params)
    {
      mango_id:           mango_params['Id'],
      mango_author_id:    mango_params['AuthorId'],
      mango_status:       mango_params['Status'],
      mango_card_id:      mango_params['CardId'],
      mango_redirect_url: mango_params['SecureModeRedirectURL'],
      mango_result_code:  mango_params['ResultCode'],
    }
  end
end
