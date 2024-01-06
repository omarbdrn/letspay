class AddTermsUrlToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :terms_url, :string
  end
end
