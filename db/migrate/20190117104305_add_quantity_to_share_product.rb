class AddQuantityToShareProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :share_products, :quantity, :integer, default: 1, null: false   
  end
end
