class CreateShareProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :share_products, id: :uuid do |t|
      t.belongs_to :product, foreign_key: true, type: :uuid
      t.belongs_to :share, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
