class CreateNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :notifications, id: :uuid do |t|
      t.belongs_to :account, foreign_key: true
      t.belongs_to :purchase, foreign_key: true, type: :uuid

      t.timestamps
    end

    add_index :notifications, [:account_id, :purchase_id], unique: true
  end
end
