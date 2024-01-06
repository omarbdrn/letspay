class AddApiKeyToPayorInfo < ActiveRecord::Migration[5.0]
  def change
    add_column :payor_infos, :api_key, :string
  end
end
