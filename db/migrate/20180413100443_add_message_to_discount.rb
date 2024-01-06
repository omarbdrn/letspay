class AddMessageToDiscount < ActiveRecord::Migration[5.0]
  def change
    add_column :discounts, :message, :string
  end
end
