class AddWebhooksUrlToMerchant < ActiveRecord::Migration[5.0]
  def change
    add_column :merchants, :webhooks_url, :string
  end
end
