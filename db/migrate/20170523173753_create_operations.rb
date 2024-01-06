class CreateOperations < ActiveRecord::Migration[5.0]
  def change
    create_table :operations do |t|
      t.string :mangopay_id
      t.string :mangopay_user_id
      t.datetime :failed_at
      t.string :failed_reason

      t.references :share, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
