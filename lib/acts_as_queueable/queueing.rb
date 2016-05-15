module ActsAsQueueable
  class Queueing < ::ActiveRecord::Base #:nodoc:
    #TODO, remove from 4.0.0
    attr_accessible :tag,
                    :queue_id,
                    :queueable,
                    :queueable_type,
                    :queueable_id,
                    :queuer,
                    :queuer_type,
                    :queuer_id if defined?(ActiveModel::MassAssignmentSecurity)

    belongs_to :queue, class_name: '::ActsAsQueueable::Queue', counter_cache: true
    belongs_to :queueable, polymorphic: true
    belongs_to :queuer,   polymorphic: true

    validates_presence_of :queue_id

    validates_uniqueness_of :queue_id, scope: [:queueable_type, :queueable_id, :queuer_id, :queuer_type]
  end
end
