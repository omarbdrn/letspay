class UpdateOperations < ActiveRecord::Migration[5.0]
  def change
    remove_column :operations, :mangopay_id
    remove_column :operations, :mangopay_user_id

    add_column :operations, :type, :string
    add_column :operations, :mango_id, :string
    add_column :operations, :mango_author_id, :string
    add_column :operations, :mango_status, :string
    add_column :operations, :mango_card_id, :string
    add_column :operations, :mango_redirect_url, :string
  end
end
