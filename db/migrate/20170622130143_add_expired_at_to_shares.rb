class AddExpiredAtToShares < ActiveRecord::Migration[5.0]
  def change
    add_column :shares, :expired_at, :datetime, null: :false
  end
end
