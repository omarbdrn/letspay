class CreateCards < ActiveRecord::Migration[5.0]
  def change
    create_table :cards do |t|
      t.belongs_to :payor_info, foreign_key: true
      t.string :mango_card_id
      t.string :card_type
      t.string :currency
      t.timestamps
    end
  end
end
