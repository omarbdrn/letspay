class AddPolymporphicRelationToOperation < ActiveRecord::Migration[5.0]
  def up
    add_reference :operations, :traceable, polymorphic: true, index: true, type: :uuid
    Operation.find_each do |op|
      op.traceable_type = 'Share'
      op.traceable_id = op.share_id
      op.save
    end
    remove_column :operations, :share_id
  end

  def down
    add_column :operations, :share_id, :uuid
    Operation.find_each do |op|
      op.traceable_type = 'Share'
      op.save
    end
    remove_column :operations, :traceable_type
    remove_column :operations, :traceable_id
  end
end
