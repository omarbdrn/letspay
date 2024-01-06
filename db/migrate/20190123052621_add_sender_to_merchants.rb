class AddSenderToMerchants < ActiveRecord::Migration[5.0]
  def change
    add_column :merchants, :sender, :string
  end
end
