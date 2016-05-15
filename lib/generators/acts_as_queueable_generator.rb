# frozen_string_literal: true
class ActsAsQueueableGenerator < Rails::Generators::NamedBase
  def generate
    timestamp = Time.zone.now.to_i
    file = "db/migrate/acts_as_queueable_setup_#{timestamp}.rb"
    create_file file, <<-FILE.strip_heredoc
        class ActsAsqueueableSetupMigration < ActiveRecord::Migration
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

            add_index :queues, :name, unique: true

            remove_index :queueings, :tag_id
            remove_index :queueings, [:queueable_id, :queueable_type]
            add_index :queueings,
                      [:tag_id, :queueable_id, :queueable_type, :queuer_id, :queuer_type],
                      unique: true, name: 'queueings_idx'

            add_column :tags, :queueings_count, :integer, default: 0

            ActsAsQueueable::Queue.reset_column_information
            ActsAsQueueable::Queue.find_each do |queue|
              ActsAsQueueable::Queue.reset_counters(queue.id, :queueings)
            end

            add_index :queueings, [:queueable_id, :queueable_type]

            if ActsAsQueueable::Utitls.using_mysql?
              execute("ALTER TABLE tags MODIFY name varchar(255) CHARACTER SET utf8 COLLATE utf8_bin;")
            end

            add_index :queueings, :tag_id
            add_index :queueings, :queueable_id
            add_index :queueings, :queueable_type
            add_index :queueings, :queuer_id

            add_index :queueings, [:queuer_id, :queuer_type]
            add_index :queueings, [:queueable_id, :queueable_type, :queuer_id], name: 'queueings_idy'
          end

          def self.down
            drop_table :queueings
            drop_table :queues

            remove_index :queues, :name

            remove_index :queueings, name: 'queueings_idx'
            remove_index :queueings, :tag_id
            remove_index :queueings, [:queueable_id, :queueable_type]

            remove_column :queues, :queueings_count

            remove_index :queueings, [:queueable_id, :queueable_type]

            remove_index :queueings, :tag_id
            remove_index :queueings, :queueable_id
            remove_index :queueings, :queueable_type
            remove_index :queueings, :queuer_id

            remove_index :queueings, [:queuer_id, :queuer_type]
            remove_index :queueings, [:queueable_id, :queueable_type, :queuer_id], name: 'queueings_idy'
          end
        end
      FILE
  end
end
