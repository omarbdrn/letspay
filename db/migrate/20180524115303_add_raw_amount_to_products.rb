class AddRawAmountToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :raw_amount_cents, :integer, default: 0, null: false
    update_raw_amounts
  end

  def update_raw_amounts
    Product.find_each do |product|
      product.update(raw_amount_cents: product.amount_cents)
    end
  end
end
