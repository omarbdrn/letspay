class AddButtonToMerchants < ActiveRecord::Migration[5.0]
  def change
    add_column :merchants, :white_label_button_color, :string, default: '' 
  end
end
