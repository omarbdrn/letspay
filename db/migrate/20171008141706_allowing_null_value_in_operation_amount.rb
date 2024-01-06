class AllowingNullValueInOperationAmount < ActiveRecord::Migration[5.0]
  def change
    change_column :operations, :amount_cents, :integer, null: true
    change_column :operations, :amount_currency, :string, null: true
  end
end
