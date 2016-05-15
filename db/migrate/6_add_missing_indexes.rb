class AddMissingIndexes < ActiveRecord::Migration
  def change
    add_index :queueings, :tag_id
    add_index :queueings, :queueable_id
    add_index :queueings, :queueable_type
    add_index :queueings, :queuer_id

    add_index :queueings, [:queuer_id, :queuer_type]
    add_index :queueings, [:queueable_id, :queueable_type, :queuer_id], name: 'queueings_idy'
  end
end
