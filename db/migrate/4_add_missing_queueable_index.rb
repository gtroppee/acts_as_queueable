class AddMissingQueueableIndex < ActiveRecord::Migration
  def self.up
    add_index :queueings, [:queueable_id, :queueable_type]
  end

  def self.down
    remove_index :queueings, [:queueable_id, :queueable_type]
  end
end
