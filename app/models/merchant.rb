# frozen_string_literal: true
# == Schema Information
#
# Table name: merchants
#
#  id                                             :integer          not null, primary key
#  name                                           :string           not null
#  api_key                                        :string           not null
#  site_url                                       :string           not null
#  terms_url                                      :string           not null
#  default_locale                                 :string           default("en"), not null
#  created_at                                     :datetime         not null
#  updated_at                                     :datetime         not null
#  mango_id                                       :string
#  mango_wallet_id                                :string
#  slug                                           :string
#  commission_percent_thousandth                  :integer          default(0)
#  webhooks_url                                   :string
#  picture_url                                    :string
#  email_ticket                                   :string
#  pay_out_frequency                              :string
#  service_fee_cents                              :integer          default(0), not null
#  currency                                       :string           default("USD")
#  auto_redirect_to_merchant_url                  :boolean          default(FALSE)
#  next_pay_out_date                              :date
#  verify_webhook_response                        :boolean          default(FALSE)
#  dispatchable_cart                              :boolean          default(FALSE)
#  multicard_mode                                 :boolean          default(FALSE)
#  multicard_letspayer_participation_round_in_hours :integer
#  multicard_leader_last_chance_round_in_hours    :integer
#  payout_summary_email                           :string
#

class Merchant < ApplicationRecord
  extend FriendlyId
  extend Enumerize
  friendly_id :name, use: :slugged

  API_KEY_LENGTH = 64
  SECRET_TOKEN_LENGTH = 20

  before_create :add_api_key, :add_secret_token
  after_create :create_related_mango_objects

  has_many :purchases, dependent: :restrict_with_exception
  has_and_belongs_to_many :managers, class_name: 'Account'
  has_many :discounts
  has_many :pay_outs,  -> { order(created_at: :desc) }
  has_one :bank_account

  enumerize :pay_out_frequency, in: [:daily, :weekly, :monthly], default: :monthly

  FREQUENCY_TO_PERIOD = {'daily' => :day, 'weekly' => :week, 'monthly' => :month}

  monetize :service_fee_cents, with_model_currency: :currency

  validates :name, :site_url, :terms_url, :webhooks_url, presence: true
  validates :name, uniqueness: true

  validates :site_url, :terms_url, :webhooks_url, url: true

  def commission_percent
    commission_percent_thousandth / 1000.0
  end

  def filtered_purchases(filter)
    purchases.by_partial_merchant_reference_or_email_or_title(filter)
  end

  def active_discount
    discounts.active.first
  end

  def mango_bank_account_id
    bank_account.try(:mango_id)
  end

  def wallet_balance_amount
    Money.new(wallet_balance_amount_cents, wallent_balance_currency)
  end

  def wallet_balance_amount_cents
    mango_wallet.dig("Balance", "Amount")
  end

  def wallet_balance_is_not_empty?
    wallet_balance_amount_cents.present? && wallet_balance_amount_cents > 0
  end

  def wallent_balance_currency
    mango_wallet.dig("Balance", "Currency")
  end

  def next_payout_amount_cents
    pay_out_frequency.daily? ? [transfers_amount_cents_between_last_payout_and_yesterday, wallet_balance_amount_cents].min : wallet_balance_amount_cents
  end

  def last_payout_time
    pay_outs.first.try(:created_at) || self.created_at
  end

  def should_receive_payout_now?
    bank_account.present? && bank_account.mango_valid? && wallet_balance_is_not_empty? && payout_is_past_due?
  end

  def payout_is_past_due?
    Time.zone.now >= next_pay_out_date
  end

  def pay_out_period
    1.send(FREQUENCY_TO_PERIOD[pay_out_frequency])
  end

  def next_pay_out_date
    self[:next_pay_out_date] || last_payout_time + pay_out_period
  end

  def update_next_pay_out_date!
    update_attribute(:next_pay_out_date, last_payout_time + pay_out_period)
  end

  def transfers_between(from, to)
    transfers = Transfer.joins('JOIN purchases on purchases.id = operations.traceable_id')
    transfers = transfers.where(traceable_type: 'Purchase', mango_status: Mango::SUCCEEDED_OPERATION_STATUS).where('purchases.merchant_id = ?', id)
    transfers = transfers.where('operations.created_at >= ? AND operations.created_at < ?', from, to)
    transfers
  end

  def transfers_between_last_payout_and_yesterday
    Time.use_zone merchant_timezone do
      transfers_between(last_payout_time.in_time_zone.beginning_of_day, Time.now.end_of_day - 1.day)
    end
  end

  def transfers_amount_cents_between_last_payout_and_yesterday
    transfers_between_last_payout_and_yesterday.sum(:amount_cents)
  end

  def merchant_timezone
    'Europe/Paris'
  end

  private

  def add_api_key
    self.api_key = Devise.friendly_token(API_KEY_LENGTH)
  end

  def add_secret_token
    self.secret_token = SecureRandom.hex(SECRET_TOKEN_LENGTH)
  end

  def mango_wallet
    @wallet ||= Mango::Wallet.new.show(self)
  end

  def create_related_mango_objects
    return unless ENV['MANGO_SYNC_ENABLED']
    Mango::LegalUser.new.create(self)
    Mango::Wallet.new.create(self)
  end

end
