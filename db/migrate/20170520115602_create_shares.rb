class CreateShares < ActiveRecord::Migration[5.0]
  def change
    create_table :shares, id: :uuid do |t|
      t.string :email, null: false
      t.string :first_name
      t.string :last_name

      t.references :purchase, null: false, index: true, foreign_key: true, type: :uuid
      t.references :account, foreign_key: true

      t.monetize :amount

      t.timestamps
    end
  end
end
