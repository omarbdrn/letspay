class AddNextPayOutDateToMerchant < ActiveRecord::Migration[5.0]
  def change
    add_column :merchants, :next_pay_out_date, :date
  end
end
