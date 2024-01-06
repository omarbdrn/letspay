class AddMetadataToShareProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :share_products, :metadata, :jsonb, null: false, default: '{}'  
  end
end
