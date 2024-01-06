class AddLanguageToPayorInfos < ActiveRecord::Migration[5.0]
  def change
    add_column :payor_infos, :language, :string
  end
end
