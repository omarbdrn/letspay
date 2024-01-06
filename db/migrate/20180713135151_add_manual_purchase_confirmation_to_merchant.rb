class AddManualPurchaseConfirmationToMerchant < ActiveRecord::Migration[5.0]
  def change
    add_column :merchants, :manual_purchase_confirmation_mode, :boolean, default: false
  end
end
