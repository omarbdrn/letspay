class AddMaximumParticipantsNumberToPurchase < ActiveRecord::Migration[5.0]
  def change
    add_column :purchases, :maximum_participants_number, :integer
  end
end
