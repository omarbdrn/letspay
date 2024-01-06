class AddInitialTransactionIdAndTypeToOperation < ActiveRecord::Migration[5.0]
  def change
    add_column :operations, :initial_transaction_mango_id, :string
    add_column :operations, :initial_transaction_type, :string
  end
end
