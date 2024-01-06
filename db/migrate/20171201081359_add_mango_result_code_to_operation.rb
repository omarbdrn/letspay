class AddMangoResultCodeToOperation < ActiveRecord::Migration[5.0]
  def change
    add_column :operations, :mango_result_code, :string
  end
end
