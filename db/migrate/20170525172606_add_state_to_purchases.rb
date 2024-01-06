class AddStateToPurchases < ActiveRecord::Migration[5.0]
  def change
    add_column :purchases, :state, :integer, default: 0, null: false
  end
end
