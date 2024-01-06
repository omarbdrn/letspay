class AddWhiteLabelToMerchants < ActiveRecord::Migration[5.0]
  def change
    add_column :merchants, :white_label, :boolean, default: false 
  end
end
