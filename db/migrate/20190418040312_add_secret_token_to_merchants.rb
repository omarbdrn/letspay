class AddSecretTokenToMerchants < ActiveRecord::Migration[5.0]
  def change
    add_column :merchants, :secret_token, :string
  end
end
