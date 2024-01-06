class CreateDiscountPurchases < ActiveRecord::Migration[5.0]
  def change
    create_table :discount_purchases, id: :uuid do |t|
      t.belongs_to :discount, foreign_key: true
      t.references :purchase, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
