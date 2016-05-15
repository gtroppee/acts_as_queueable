class ActsAsqueueableMigration < ActiveRecord::Migration
  def self.up
    create_table :queues do |t|
      t.string :name
    end

    create_table :queueings do |t|
      t.references :queue
      t.integer :weight, null: false, default: 1

      t.references :queueable, polymorphic: true
      t.references :queuer, polymorphic: true

      t.datetime :created_at
    end

    add_index :queueings, :tag_id
    add_index :queueings, [:queueable_id, :queueable_type]
  end

  def self.down
    drop_table :queueings
    drop_table :queues
  end
end
