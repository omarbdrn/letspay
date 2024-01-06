# frozen_string_literal: true

module LetsPay
  class Logger
    def initialize(tags)
      @tags = tags
    end

    def debug
      with_tags do |logger|
        logger.debug yield
      end
    end

    def info
      with_tags do |logger|
        logger.info yield
      end
    end

    def warn
      with_tags do |logger|
        logger.warn yield
      end
    end

    def error
      with_tags do |logger|
        logger.error yield
      end
    end

    private

    attr_reader :tags

    def with_tags
      logger.tagged(tags) do |tagged_logger|
        yield tagged_logger
      end
    end

    def logger
      if Rails.env.test?
        @logger ||= ActiveSupport::TaggedLogging.new(Rails.logger)
      else
        @logger ||= ActiveSupport::TaggedLogging.new(Le.new(ENV['LOGENTRIES_TOKEN'], debug: ENV['LOGENTRIES_DEBUG'], local: !ENV['LOGENTRIES_LOCAL'].nil?, ssl: true, tag: true))
      end
    end
  end
end
