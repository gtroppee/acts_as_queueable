module ActsAsQueueable
  module Queuer
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

      def acts_as_queuer
        class_eval do
          has_many :queueings,  as: :queuer,
                                dependent: :destroy,
                                class_name: '::ActsAsQueueable::Queueing'

          has_many :queues, through: :queueings,
                            class_name: '::ActsAsQueueable::Queue'
        end

        include ActsAsQueueable::Queuer::InstanceMethods
        extend ActsAsQueueable::Queuer::SingletonMethods
      end

      def queuer?
        false
      end

      def is_queuer?
        queuer?
      end
    end

    module InstanceMethods

      def enqueue(queueable, queue_name = DEFAULT_QUEUE_NAME)
        queue = Queue.find_or_create_by_name(queue_name)
        Queueing.create(queueable: queueable, queuer: self, queue: queue)
      end

      def dequeue(queueable, queue_name = DEFAULT_QUEUE_NAME)
        queue = Queue.find_or_create_by_name(queue_name)
        Queueing.where(queueable: queueable, queuer: self, queue: queue).destroy_all
      end

      def queuer?
        self.class.is_queuer?
      end

      def is_queuer?
        queuer?
      end
    end

    module SingletonMethods
      def queuer?
        true
      end

      def is_queuer?
        queuer?
      end
    end
  end
end
