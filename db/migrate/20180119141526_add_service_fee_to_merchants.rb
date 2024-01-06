class AddServiceFeeToMerchants < ActiveRecord::Migration[5.0]
  def change
    add_column :merchants, :service_fee_cents, :integer, default: 0, null: false
    add_column :merchants, :currency, :string, default: 'USD'
    change_column_default :merchants, :commission_percent_thousandth, from: nil, to: 0
    remove_column :merchants, :commission_paid_by_letspayer, :boolean
  end
end
