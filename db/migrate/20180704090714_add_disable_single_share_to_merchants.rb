class AddDisableSingleShareToMerchants < ActiveRecord::Migration[5.0]
  def change
    add_column :merchants, :disable_single_share, :boolean, default: false
  end
end
