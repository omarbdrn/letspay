class AddFieldsForPreAuthExecutionToOperation < ActiveRecord::Migration[5.0]
  def change
    add_column :operations, :pay_in_executed_at, :datetime
    add_column :operations, :pay_in_mango_id, :string
  end
end
