class RemoveFirstNameAndLastNameFromShare < ActiveRecord::Migration[5.0]
  def change
    remove_column :shares, :first_name
    remove_column :shares, :last_name
  end
end
