class AddAmountToOperation < ActiveRecord::Migration[5.0]
  def change
    add_monetize :operations, :amount
  end
end
