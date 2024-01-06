class AddDispatchableCartToMerchants < ActiveRecord::Migration[5.0]
  def change
    add_column :merchants, :dispatchable_cart, :boolean, default: false    
  end
end
