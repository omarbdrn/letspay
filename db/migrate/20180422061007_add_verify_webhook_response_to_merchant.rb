class AddVerifyWebhookResponseToMerchant < ActiveRecord::Migration[5.0]
  def change
    add_column :merchants, :verify_webhook_response, :boolean, default: false
  end
end
