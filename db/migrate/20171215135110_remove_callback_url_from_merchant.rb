class RemoveCallbackUrlFromMerchant < ActiveRecord::Migration[5.0]
  def change
    remove_column :merchants, :callback_url
  end
end
