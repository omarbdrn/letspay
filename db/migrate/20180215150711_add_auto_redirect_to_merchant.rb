class AddAutoRedirectToMerchant < ActiveRecord::Migration[5.0]
  def change
    add_column :merchants, :auto_redirect_to_merchant_url, :boolean, default: false
  end
end
