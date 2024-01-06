# frozen_string_literal: true

# == Schema Information
#
# Table name: cards
#
#  id            :integer          not null, primary key
#  payor_info_id :integer
#  mango_card_id :string
#  card_type     :string
#  currency      :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Card < ApplicationRecord
  belongs_to :payor_info
  validates :mango_card_id, presence: :true
end
