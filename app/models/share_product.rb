# == Schema Information
#
# Table name: share_products
#
#  id         :uuid             not null, primary key
#  product_id :uuid
#  share_id   :uuid
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ShareProduct < ApplicationRecord
  belongs_to :share
  belongs_to :product

  validates :share, :product, presence: true
  validates :product, uniqueness: true # A product can only belong to one share
end
