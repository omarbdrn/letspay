# frozen_string_literal: true

module Mango
  class Base

    def initialize
      @logger = LetsPay::Logger.new(self.class.name)
    end

    attr_reader :error, :logger, :result

    def handle_mango_error(ex, options = {} )
      @error = ex
      Rollbar.error("Mango API error: class=#{self.class.name} details=#{error.details}, message=#{error_message}  extra=#{options[:extra]}")
      @logger.error { "Error when executing a mango request : #{error_message}" }
      false
    end

    def error_message
      @error.to_s
    end

    def success?
      !defined? @error
    end

  end
end
