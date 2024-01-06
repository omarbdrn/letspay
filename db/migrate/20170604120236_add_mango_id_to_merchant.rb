class AddMangoIdToMerchant < ActiveRecord::Migration[5.0]
  def change
    add_column :merchants, :mango_id, :string
  end
end
