class AddSharesCountToPurchases < ActiveRecord::Migration[5.0]
  def change
    add_column :purchases, :shares_count, :integer, null: false, default: 0
  end
end
