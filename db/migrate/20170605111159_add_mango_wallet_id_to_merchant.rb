class AddMangoWalletIdToMerchant < ActiveRecord::Migration[5.0]
  def change
    add_column :merchants, :mango_wallet_id, :string
  end
end
