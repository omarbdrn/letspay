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

class Purchase < ApplicationRecord

  MANUAL_CONFIRMATION_EXPIRATION_TIME_IN_DAYS = 5

  belongs_to :merchant
  has_many :accounts, through: :notifications
  has_many :notifications
  belongs_to :leader_share, class_name: 'Share', optional: true
  has_many :shares, dependent: :restrict_with_exception
  has_many :products, dependent: :destroy

  has_one :transfer,            -> { order(created_at: :desc).limit(1) }, as: :traceable
  has_one :refund,              -> { order(created_at: :desc).limit(1) }, as: :traceable
  has_one :applied_discount, class_name: 'DiscountPurchase'
  has_many :transfers,          -> { order(created_at: :desc) }, as: :traceable
  has_many :refunds,            -> { order(created_at: :desc) }, as: :traceable
  has_many :operations,                                          as: :traceable
  has_many :successfull_pay_ins, through: :shares, class_name: 'PayIn'
  has_many :payor_infos, through: :shares

  enum state: %w(INITIALIZED CANCELLED FAILED LEADER_PROCESSED SUCCESSFUL PARTIALLY_REFUNDED REFUNDED MULTICARD_LETSPAYER_ROUND_TIMEOUT MULTICARD_ERROR WAITING_MERCHANT_VALIDATION MULTICARD_CONFIRMED PARTIALLY_SUCCESSFUL)

  monetize :amount_cents
  monetize :raw_amount_cents, with_model_currency: :amount_currency
  monetize :discount_cents, with_model_currency: :amount_currency
  monetize :amount_to_pay_cents, with_model_currency: :amount_currency
  monetize :remaining_amount_cents, with_model_currency: :amount_currency
  monetize :paid_amount_cents, with_model_currency: :amount_currency
  monetize :multicard_remaining_amount_cents, with_model_currency: :amount_currency

  validates :title, :merchant, :merchant_reference, presence: true
  validates :maximum_participants_number, numericality: { only_integer: true, greater_than_or_equal_to: 2, allow_nil: true }
  validate  :product_amount_sum_must_equal_purchase_amount

  delegate :expired_at, :timezone, to: :leader_share, allow_nil: true
  delegate :email, :amount, :last_name, :first_name, :full_name, :amount_to_pay, to: :leader_share, prefix: 'leader', allow_nil: true
  delegate :name, :picture_url, :slug, :multicard_mode, :manual_purchase_confirmation_mode, :manual_multicard_mode, :white_label, :white_label_button_color, to: :merchant, prefix: true

  scope :by_partial_merchant_reference, ->(ref_chunk) { where(merchant_reference_matches(ref_chunk)) }
  scope :by_partial_merchant_reference_or_email_or_title, ->(filter) { joins(left_outer_join_leader_share).where(merchant_reference_matches(filter).or(Share.email_matches(filter)).or(title_matches(filter))) }

  scope :cancelled,                         -> { where(state: ['FAILED', 'CANCELLED']) }
  scope :successful,                        -> { where(state: ['SUCCESSFUL', 'LEADER_PROCESSED']) }
  scope :refunded,                          -> { where(state: ['PARTIALLY_REFUNDED', 'REFUNDED']) }
  scope :multicard,                         -> { joins(:merchant).where("merchants.multicard_mode = ?", true) }
  scope :not_manual_multicard,              -> { joins(:merchant).where("merchants.manual_multicard_mode = ?", false) }
  scope :multicard_letspayer_round_timeout,   -> { multicard.where(state: 'MULTICARD_LETSPAYER_ROUND_TIMEOUT') }
  scope :manual_purchase_confirmation_mode, -> { joins(:merchant).where("merchants.manual_purchase_confirmation_mode = ?", true) }
  scope :waiting_merchant_validation,       -> { where(state: 'WAITING_MERCHANT_VALIDATION') }
  scope :manual_confirmation_outdated,      -> { waiting_merchant_validation.joins(leader_share: :pre_authorization).where('operations.created_at < ?', Time.current - MANUAL_CONFIRMATION_EXPIRATION_TIME_IN_DAYS.days) }
  scope :multicard_preauth_succeeded,       -> { multicard.not_manual_multicard.joins(leader_share: :pre_authorization).where('operations.mango_status = ? AND operations.pay_in_executed_at IS ?', Mango::SUCCEEDED_OPERATION_STATUS, nil) }

  def commission_amount_cents
    (raw_amount_cents * (merchant.commission_percent || 0)) / 100
  end

  def letspayer_shares
    shares.reject(&:leader?)
  end

  def letspayer_shares_with_pay_in
    shares.includes(:pay_in).reject(&:leader?)
  end

  def paid_amount_cents
    shares.includes(:pay_in).select(&:paid?).sum(&:amount_to_pay_cents)
  end

  def pre_authorized_amount_cents
    shares.includes(:pre_authorization).select(&:pre_authorized?).sum(&:amount_to_pay_cents)
  end

  def pre_authorized_commission_amount_cents
    (pre_authorized_amount_cents * (merchant.commission_percent || 0)) / 100
  end

  def paid_shares
    shares.select(&:paid?)
  end

  def unpaid_shares
    shares.select(&:unpaid?)
  end

  def multicard_remaining_amount_cents
    amount_to_pay_cents - pre_authorized_amount_cents
  end

  def remaining_amount_cents
    amount_to_pay_cents - paid_amount_cents
  end

  def refunded_amount_cents
    shares.select(&:refunded?).sum(&:refunded_amount_cents)
  end

  def max_refund_percent
    100 - refunded_amount_percent
  end

  def refundable?
    merchant.wallet_balance_amount >= amount
  end

  def all_friends_have_paid?
    leader_share.pay_in.try(:amount_cents) == leader_share.amount_cents
  end

  def all_friends_have_preauthorized?
    multicard_remaining_amount_cents == 0
  end

  def mark_as_refunded!
    update(state: (totaly_refunded? ? :REFUNDED : :PARTIALLY_REFUNDED))
  end

  def discount_cents
    raw_amount_cents - amount_cents
  end

  def discount_message
    merchant.discounts.active.select(&:display_message?).first.try(:message)
  end

  def amount_to_pay_cents
    shares.sum(&:amount_to_pay_cents)
  end

  def language
    leader_share.try(:payor_info).try(:language) || I18n.default_locale
  end

  def discount_applied
    applied_discount.present?
  end

  def discount_code
    applied_discount.discount.code if discount_applied
  end

  def discount_code_with_amount_or_percentage
    applied_discount.discount.code_with_amount_or_percentage if discount_applied
  end

  def pre_authorized_shares_count
    letspayer_shares.select(&:pre_authorized?).size
  end

  def all_pre_authorized_shares_count
    shares.select(&:pre_authorized?).size
  end

  def missing_pre_authorized_shares_count
    letspayer_shares.size - pre_authorized_shares_count
  end

  def should_close_letspayer_participation_round?
    (all_shares_are_pre_authorized? || letspayer_participation_round_is_timed_out?) && purchase_is_in_multicard_mode? && (MULTICARD_CONFIRMED? || LEADER_PROCESSED?)
  end

  def all_shares_are_pre_authorized?
    shares.reduce(true) do |all_pre_authorized, share|
      all_pre_authorized && share.pre_authorized?
    end
  end

  def letspayer_participation_round_is_timed_out?
    letspayer_participation_round_expiration_date <= Time.current
  end

  def should_start_leader_last_chance_round?
    !all_shares_are_pre_authorized?
  end

  def multicard_leader_last_chance_round_in_days_from_now
    ((leader_share.multicard_leader_last_chance_round_expiration_time - Time.now) / 1.day).to_i
  end

  def multicard_letspayer_participation_round_in_days_from_now
    ((letspayer_participation_round_expiration_date - Time.now) / 1.day).to_i
  end

  def letspayer_participation_round_expiration_in_days
    (letspayer_participation_round_expiration_in_hours / 1.day).to_i
  end

  private

  def totaly_refunded?
    refunded_amount_cents == amount_cents
  end

  def refunded_amount_percent
    (refunded_amount_cents * 100) / amount_cents
  end

  def self.merchant_reference_matches(ref_chunk)
    arel_table[:merchant_reference].matches("%#{ref_chunk}%")
  end

  def self.title_matches(ref_chunk)
    arel_table[:title].matches("%#{ref_chunk}%")
  end

  def self.left_outer_join_leader_share
    share_table = Share.arel_table
    arel_table.join(share_table, Arel::Nodes::OuterJoin).on(arel_table[:leader_share_id].eq(share_table[:id])).join_sources
  end

  def product_amount_sum_must_equal_purchase_amount
    if merchant.try(:dispatchable_cart?) && products.size > 0 && products.map{ |product| product.raw_amount_cents }.sum != raw_amount_cents
      errors.add(:amount_cents, "product amount sum must equal purchase amount")
    end
  end

  def purchase_is_in_multicard_mode?
    merchant.multicard_mode?
  end

  def letspayer_participation_round_expiration_in_hours
    (merchant.try(:multicard_letspayer_participation_round_in_hours) || Share::MULTICARD_LETSPAYER_PARTICIPATION_ROUND_IN_HOURS).hours
  end

  def letspayer_participation_round_expiration_date
    if merchant.try(:manual_multicard_mode)
      multicard_confirmed_executed_at + letspayer_participation_round_expiration_in_hours
    else
      created_at + letspayer_participation_round_expiration_in_hours
    end
  end
end
