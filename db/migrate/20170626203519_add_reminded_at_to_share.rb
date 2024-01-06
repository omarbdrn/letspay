class AddRemindedAtToShare < ActiveRecord::Migration[5.0]
  def change
    add_column :shares, :reminded_at, :datetime
  end
end
