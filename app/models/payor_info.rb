# frozen_string_literal: true
# == Schema Information
#
# Table name: payor_infos
#
#  id                   :integer          not null, primary key
#  email                :string
#  first_name           :string
#  last_name            :string
#  birthday             :date
#  nationality          :string
#  country_of_residence :string
#  mango_id             :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  optin                :boolean          default(TRUE)
#  timezone             :string
#  language             :string
#

class PayorInfo < ApplicationRecord
  has_many :shares, inverse_of: :payor_info
  has_many :cards, inverse_of: :payor_info

  validates :email, presence: true
  validates :email, uniqueness: true
  before_save :only_existing_timezone
  before_create :set_api_key

  DEFAULT_TIMEZONE = "Europe/Paris"
  API_KEY_LENGTH   = 64

  def default_mango_card_id
    cards.order(:created_at).last.try(:mango_card_id)
  end

  def related_mango_user_exist?
    mango_id.present?
  end

  def add_card_from_attributes(card_attrs)
    cards.create!(card_attrs)
  end

  def full_name
    _full_name = "#{first_name} #{last_name}"
    _full_name.present? ? _full_name : email
  end

  def set_api_key
    self.api_key ||= Devise.friendly_token(API_KEY_LENGTH)
  end

  private

  def only_existing_timezone
    self.timezone = nil unless ActiveSupport::TimeZone::MAPPING.values.include?(self.timezone)
  end
end
