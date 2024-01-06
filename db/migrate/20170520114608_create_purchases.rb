class CreatePurchases < ActiveRecord::Migration[5.0]
  def change
    create_table :purchases, id: :uuid do |t|
      t.string :title, null: false
      t.string :callback_url, null: false
      t.string :merchant_reference, null: false
      t.string :subtitle
      t.string :description
      t.string :picture_url
      t.string :comment

      t.references :merchant, foreign_key: true, null: false
      t.monetize :amount

      t.timestamps
    end
  end
end
