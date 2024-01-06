class AddTimeoutToPurchases < ActiveRecord::Migration[5.0]
  def change
    add_column :purchases, :timeout_seconds, :integer, default: 0
  end
end
