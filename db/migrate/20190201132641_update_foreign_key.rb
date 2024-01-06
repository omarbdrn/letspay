class UpdateForeignKey < ActiveRecord::Migration[5.0]
  def change
    # remove the old foreign_key
    remove_foreign_key :share_products, :products

    # add the new foreign_key
    add_foreign_key :share_products, :products, on_delete: :cascade    
  end
end
