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

        def in_queue_for?(queuer, index = nil, queue_name = DEFAULT_QUEUE_NAME)
          return false if queues.empty?

          queue = Queue.includes(:queueings).find_by(name: queue_name)
          queueings = queuer.queueings

          if index
            queueings[index].queueable == self
          else
            queueings.any? { |queueing| queueings.map(&:queueable).include?(queueing.queueable) }
          end
        end

        def first_in_queue_for?(queuer, queue_name = DEFAULT_QUEUE_NAME)
          in_queue_for?(queuer, 0)
        end
      end
    end
  end
end
