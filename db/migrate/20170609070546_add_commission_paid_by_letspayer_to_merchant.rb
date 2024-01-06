class AddCommissionPaidByLetsPayerToMerchant < ActiveRecord::Migration[5.0]
  def change
    add_column :merchants, :commission_paid_by_letspayer, :boolean, default: true
  end
end
