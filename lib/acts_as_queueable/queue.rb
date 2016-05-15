# encoding: utf-8
module ActsAsQueueable
  class Queue < ::ActiveRecord::Base

    attr_accessible :name if defined?(ActiveModel::MassAssignmentSecurity)

    ### ASSOCIATIONS:

    has_many :queueings, dependent: :destroy, class_name: '::ActsAsQueueable::Queueing'

    ### VALIDATIONS:

    validates_presence_of :name
    validates_uniqueness_of :name, if: :validates_name_uniqueness?
    validates_length_of :name, maximum: 255

    # monkey patch this method if don't need name uniqueness validation
    def validates_name_uniqueness?
      true
    end

    def self.named(name)
      if ActsAsQueueable.strict_case_match
        where(["name = #{binary}?", as_8bit_ascii(name)])
      else
        where(['LOWER(name) = LOWER(?)', as_8bit_ascii(unicode_downcase(name))])
      end
    end

    ### CLASS METHODS:

    def self.find_or_create_by_name(name)
      named(name).first || create(name: name)
    end

    ### INSTANCE METHODS:

    def ==(object)
      super || (object.is_a?(Queue) && name == object.name)
    end

    def to_s
      name
    end

    def count
      read_attribute(:count).to_i
    end

    class << self

      private

      def binary
        ActsAsQueueable::Utils.using_mysql? ? 'BINARY ' : nil
      end

      def unicode_downcase(string)
        if ActiveSupport::Multibyte::Unicode.respond_to?(:downcase)
          ActiveSupport::Multibyte::Unicode.downcase(string)
        else
          ActiveSupport::Multibyte::Chars.new(string).downcase.to_s
        end
      end

      def as_8bit_ascii(string)
        if defined?(Encoding)
          string.to_s.dup.force_encoding('BINARY')
        else
          string.to_s.mb_chars
        end
      end
    end
  end
end
