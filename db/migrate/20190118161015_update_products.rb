class UpdateProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :price_bounds, :jsonb, null: false, default: '{}'
    add_column :products, :variable_price, :boolean, default: false
   end
end
