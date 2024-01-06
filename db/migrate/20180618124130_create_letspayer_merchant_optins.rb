class CreateLetsPayerMerchantOptins < ActiveRecord::Migration[5.0]
  def change
    create_table :letspayer_merchant_optins, id: :uuid do |t|
      t.belongs_to :payor_info, foreign_key: true
      t.belongs_to :merchant, foreign_key: true
      t.boolean :value, default: false

      t.timestamps
    end
  end
end
