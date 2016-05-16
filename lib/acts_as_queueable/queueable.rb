module ActsAsQueueable
  module Queueable

    def acts_as_queueable
      class_eval do
        has_many :queueings, as: :queueable, dependent: :destroy, class_name: '::ActsAsQueueable::Queueing'
        has_many :queues, through: :queueings, class_name: '::ActsAsQueueable::Queue'

        def self.queueable?
          true
        end

        def queueable?
          false
        end

        def in_queue_for?(queuer, queue_name = DEFAULT_QUEUE_NAME)
          return false if queues.empty?

          queueings = Queueing.includes(:queueable)
                              .joins(:queue)
                              .where('queues.name = ?', queue_name)
                              .where(queuer: queuer)

          queueings.any? { |queueing| queueings.map!(&:queueable).include?(self) }
        end

        def first_in_queue_for?(queuer, queue_name = DEFAULT_QUEUE_NAME)
          queueing = Queueing.includes(:queueable)
                             .joins(:queue)
                             .where('queues.name = ?', queue_name)
                             .where(queuer: queuer)
                             .limit(1)
                             .first

          return false unless queueing
          queueing.queueable == self
        end
      end
    end
  end
end
