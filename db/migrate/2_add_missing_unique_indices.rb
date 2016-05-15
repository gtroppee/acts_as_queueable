class AddMissingUniqueIndices < ActiveRecord::Migration
  def self.up
    add_index :queues, :name, unique: true

    remove_index :queueings, :tag_id
    remove_index :queueings, [:queueable_id, :queueable_type]
    add_index :queueings,
              [:tag_id, :queueable_id, :queueable_type, :queuer_id, :queuer_type],
              unique: true, name: 'queueings_idx'
  end

  def self.down
    remove_index :queues, :name

    remove_index :queueings, name: 'queueings_idx'
    add_index :queueings, :tag_id
    add_index :queueings, [:queueable_id, :queueable_type]
  end
end
