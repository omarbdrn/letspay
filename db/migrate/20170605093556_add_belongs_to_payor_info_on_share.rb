class AddBelongsToPayorInfoOnShare < ActiveRecord::Migration[5.0]
  def change
    add_reference :shares, :payor_info, foreign_key: true
  end
end
