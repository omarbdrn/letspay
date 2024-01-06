class AddPictureUrlToMerchants < ActiveRecord::Migration[5.0]
  def change
    add_column :merchants, :picture_url, :string
  end
end
