class AddFieldsForManualConfirmation < ActiveRecord::Migration[5.0]
  def change
    add_column :purchases, :multicard_confirmed_executed_at, :datetime
  end
end
