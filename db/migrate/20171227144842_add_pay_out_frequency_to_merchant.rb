class AddPayOutFrequencyToMerchant < ActiveRecord::Migration[5.0]
  def change
    add_column :merchants, :pay_out_frequency, :string
  end
end
