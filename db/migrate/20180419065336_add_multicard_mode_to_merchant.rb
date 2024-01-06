class AddMulticardModeToMerchant < ActiveRecord::Migration[5.0]
  def change
    add_column :merchants, :multicard_mode, :boolean, default: false
  end
end
