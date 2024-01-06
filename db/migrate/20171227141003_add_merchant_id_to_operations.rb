class AddMerchantIdToOperations < ActiveRecord::Migration[5.0]
  def change
    add_reference :operations, :merchant, index: true
  end
end
