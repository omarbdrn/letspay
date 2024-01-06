class AddPaymentApiVersionToPurchase < ActiveRecord::Migration[5.0]
  def change
    add_column :purchases, :payment_api_version, :string, default: 'v1'
  end
end
