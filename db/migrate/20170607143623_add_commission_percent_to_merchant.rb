class AddCommissionPercentToMerchant < ActiveRecord::Migration[5.0]
  def change
    add_column :merchants, :commission_percent_thousandth, :integer, default: 1500
  end
end
