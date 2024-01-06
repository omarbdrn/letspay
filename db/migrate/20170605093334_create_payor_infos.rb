class CreatePayorInfos < ActiveRecord::Migration[5.0]
  def change
    create_table :payor_infos do |t|
      t.string :email
      t.string :first_name
      t.string :last_name
      t.date :birthday
      t.string :nationality
      t.string :country_of_residence
      t.string :mango_id

      t.timestamps
    end
  end
end
