class CreateDiscounts < ActiveRecord::Migration[5.0]
  def change
    create_table :discounts do |t|
      t.datetime :start_date
      t.datetime :end_date
      t.integer :percentage, default: 0, null: false

      t.references :merchant, index: true, foreign_key: true
    end
  end
end
