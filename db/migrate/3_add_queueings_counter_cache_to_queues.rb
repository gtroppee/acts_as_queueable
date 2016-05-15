class AddQueueingsCounterCacheToQueues < ActiveRecord::Migration
  def self.up
    add_column :tags, :queueings_count, :integer, default: 0

    ActsAsQueueable::Queue.reset_column_information
    ActsAsQueueable::Queue.find_each do |queue|
      ActsAsQueueable::Queue.reset_counters(queue.id, :queueings)
    end
  end

  def self.down
    remove_column :queues, :queueings_count
  end
end
