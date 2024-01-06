class CreateBankAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :bank_accounts, id: :uuid do |t|
      t.belongs_to :merchant, foreign_key: true
      t.string :iban
      t.string :bic
      t.string :owner_name
      t.string :owner_street
      t.string :owner_city
      t.string :owner_region
      t.string :owner_zipcode
      t.string :owner_country
      t.string :mango_id

      t.timestamps
    end
  end
end
