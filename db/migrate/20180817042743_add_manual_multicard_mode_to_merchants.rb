class AddManualMulticardModeToMerchants < ActiveRecord::Migration[5.0]
  def change
    add_column :merchants, :manual_multicard_mode, :boolean, default: false
  end
end
