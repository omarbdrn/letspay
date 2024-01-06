class AddDisplayMessageToDiscounts < ActiveRecord::Migration[5.0]
  def change
    add_column :discounts, :display_message, :boolean, default: false
  end
end
