class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products, id: :uuid do |t|
      t.string :merchant_reference
      t.string :label
      t.monetize :amount

      t.references :purchase, foreign_key: true, null: false, type: :uuid

      t.timestamps
    end
  end
end
