class CreateAccountsMerchantsRelationship < ActiveRecord::Migration[5.0]
  def change
    create_join_table :accounts, :merchants do |t|
      t.index :account_id
      t.index :merchant_id
    end

    add_foreign_key :accounts_merchants, :merchants
    add_foreign_key :accounts_merchants, :accounts
  end
end
