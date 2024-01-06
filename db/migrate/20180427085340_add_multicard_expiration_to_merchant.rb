class AddMulticardExpirationToMerchant < ActiveRecord::Migration[5.0]
  def change
    add_column :merchants, :multicard_letspayer_participation_round_in_hours, :integer
    add_column :merchants, :multicard_leader_last_chance_round_in_hours, :integer
  end
end
