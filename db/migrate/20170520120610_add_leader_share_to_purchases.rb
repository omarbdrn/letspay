class AddLeaderShareToPurchases < ActiveRecord::Migration[5.0]
  def change
    add_reference :purchases, :leader_share, foreign_key: { to_table: :shares }, index: false, type: :uuid
  end
end
