class AddPartiallySuccessfulModeToPurchases < ActiveRecord::Migration[5.0]
  def change
    add_column :purchases, :partially_successful_mode, :boolean, default: false
  end
end
