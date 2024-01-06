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

class PreAuthorization < Operation

  scope :multicard, -> { joins(:merchant).where("merchants.multicard_mode = ?", true) }

  def self.create_from_mango_params_and_share_id!(mango_params, share_id)
    PreAuthorization.create!(bind_mango_params_to_attributes(mango_params).merge(traceable_type: 'Share', traceable_id: share_id, merchant_id: Share.find(share_id).merchant.id))
  end

  def should_be_executed_now?
    pay_in_executed_at.nil? && (pre_auth_is_timed_out? || all_letspayer_shares_are_paid?) && purchase_not_refunded && !purchase_is_in_multicard_mode? && purchase_is_leader_process?
  end

  def manual_multicard_should_be_executed_now?
    pay_in_executed_at.nil? && pre_authorizations_should_be_executed_now? && purchase_is_in_manual_multicard_mode?
  end

  def can_be_executed_now?
    mango_status == Mango::SUCCEEDED_OPERATION_STATUS && pay_in_executed_at.nil?
  end

  private

  def pre_auth_is_timed_out?
    expiration_date <= Time.current
  end

  def all_letspayer_shares_are_paid?
    purchase.letspayer_shares.reduce(true) do |all_paid, share|
      all_paid && share.paid?
    end
  end

  def all_shares_are_pre_authorized?
    purchase.all_shares_are_pre_authorized?
  end

  def partially_successful_should_be_executed_now?
    multicard_purchase_is_in_partially_successful? & purchase.all_pre_authorized_shares_count.positive?
  end

  def pre_authorizations_should_be_executed_now?
    partially_successful_should_be_executed_now? || (all_shares_are_pre_authorized? && (purchase_is_in_multicard_confirmed? || multicard_purchase_is_in_letspayer_round_timeout?))
  end

  def expiration_date
    (created_at + Share::EXPIRATION_TIME_IN_DAYS.days)
  end

  def purchase_not_refunded
    purchase.try(:state) != "REFUNDED" && purchase.try(:state) != "PARTIALLY_REFUNDED"
  end

  def purchase_not_cancelled
    purchase.try(:state) != "CANCELLED"
  end

  def purchase_not_failed
    purchase.try(:state) != "FAILED"
  end

  def purchase_not_error
    purchase.try(:state) != "MULTICARD_ERROR"
  end

  def purchase_is_in_manual_multicard_mode?
    purchase.merchant.manual_multicard_mode?
  end

  def purchase_is_in_multicard_confirmed?
    purchase.try(:state) == "MULTICARD_CONFIRMED"
  end

  def purchase_is_in_multicard_mode?
    purchase.merchant.multicard_mode?
  end

  def multicard_purchase_is_not_in_letspayer_round_timeout?
    purchase.try(:state) != 'MULTICARD_LETSPAYER_ROUND_TIMEOUT'
  end

  def multicard_purchase_is_in_letspayer_round_timeout?
    purchase.try(:state) == 'MULTICARD_LETSPAYER_ROUND_TIMEOUT'
  end

  def multicard_purchase_is_in_partially_successful?
    purchase.try(:state) == 'PARTIALLY_SUCCESSFUL'
  end

  def purchase_is_leader_process?
    purchase.try(:state) == 'LEADER_PROCESSED'
  end

  def self.bind_mango_params_to_attributes(mango_params)
    {
      mango_id:           mango_params['Id'],
      mango_author_id:    mango_params['AuthorId'],
      mango_status:       mango_params['Status'],
      mango_card_id:      mango_params['CardId'],
      mango_redirect_url: mango_params['SecureModeRedirectURL'],
      mango_result_code:  mango_params['ResultCode'],
      amount_cents:       mango_params.dig('DebitedFunds', 'Amount'),
      amount_currency:    mango_params.dig('DebitedFunds', 'Currency')
    }
  end

end
