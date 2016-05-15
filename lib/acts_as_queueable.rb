require 'active_record'
require 'active_record/version'
require 'active_support/core_ext/module'

require_relative 'acts_as_queueable/engine' if defined?(Rails)

require 'digest/sha1'

module ActsAsQueueable
  DEFAULT_QUEUE_NAME = 'default'
  
  extend ActiveSupport::Autoload

  autoload :Queue
  autoload :Queueable
  autoload :Queuer
  autoload :Queueing
  autoload :VERSION

  class DuplicateTagError < StandardError
  end

  def self.setup
    @configuration ||= Configuration.new
    yield @configuration if block_given?
  end

  def self.method_missing(method_name, *args, &block)
    @configuration.respond_to?(method_name) ?
        @configuration.send(method_name, *args, &block) : super
  end

  def self.respond_to?(method_name, include_private=false)
    @configuration.respond_to? method_name
  end

  def self.glue
    setting = @configuration.delimiter
    delimiter = setting.kind_of?(Array) ? setting[0] : setting
    delimiter.ends_with?(' ') ? delimiter : "#{delimiter} "
  end

  class Configuration
    attr_accessor :force_lowercase, :force_parameterize,
                  :remove_unused_tags, :default_parser,
                  :tags_counter
    attr_reader :delimiter, :strict_case_match

    def initialize
      @delimiter = ','
      @force_lowercase = false
      @force_parameterize = false
      @strict_case_match = false
      @remove_unused_tags = false
      @tags_counter = true
      @force_binary_collation = false
    end

    def strict_case_match=(force_cs)
      @strict_case_match = force_cs unless @force_binary_collation
    end

    def delimiter=(string)
      ActiveRecord::Base.logger.warn <<WARNING
ActsAsQueueable.delimiter is deprecated \
and will be removed from v4.0+, use  \
a ActsAsQueueable.default_parser instead
WARNING
      @delimiter = string
    end

    def force_binary_collation=(force_bin)
      if Utils.using_mysql?
        if force_bin
          Configuration.apply_binary_collation(true)
          @force_binary_collation = true
          @strict_case_match = true
        else
          Configuration.apply_binary_collation(false)
          @force_binary_collation = false
        end
      end
    end

    def self.apply_binary_collation(bincoll)
      if Utils.using_mysql?
        coll = 'utf8_general_ci'
        coll = 'utf8_bin' if bincoll
        begin
          ActiveRecord::Migration.execute("ALTER TABLE tags MODIFY name varchar(255) CHARACTER SET utf8 COLLATE #{coll};")
        rescue Exception => e
          puts "Trapping #{e.class}: collation parameter ignored while migrating for the first time."
        end
      end
    end

  end

  setup
end

ActiveSupport.on_load(:active_record) do
  extend ActsAsQueueable::Queueable
  include ActsAsQueueable::Queuer
end
