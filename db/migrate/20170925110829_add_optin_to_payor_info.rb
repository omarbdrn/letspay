class AddOptinToPayorInfo < ActiveRecord::Migration[5.0]
  def change
    add_column :payor_infos, :optin, :boolean, default: true
  end
end
