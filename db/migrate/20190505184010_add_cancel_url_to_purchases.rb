class AddCancelUrlToPurchases < ActiveRecord::Migration[5.0]
  def change
    add_column :purchases, :cancel_url, :string, default: ""
  end
end