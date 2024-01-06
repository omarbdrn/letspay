class CreateMerchants < ActiveRecord::Migration[5.0]
  def change
    create_table :merchants do |t|
      t.string :name, null: false
      t.string :api_key, null: false
      t.string :site_url, null: false
      t.string :callback_url, null: false
      t.string :terms_url, null: false
      t.string :default_locale, default: 'en', null: false

      t.index :api_key, unique: true

      t.timestamps
    end


  end
end
