class AddTimezoneToPayorInfo < ActiveRecord::Migration[5.0]
  def change
    add_column :payor_infos, :timezone, :string
  end
end
