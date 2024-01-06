class AddRawAmountToPurchases < ActiveRecord::Migration[5.0]
  def change
    add_column :purchases, :raw_amount_cents, :integer, default: 0, null: false
    update_raw_amounts
  end

  def update_raw_amounts
    Purchase.all.each do |purchase|
      purchase.update(raw_amount_cents: purchase.amount_cents)
    end
  end
end
