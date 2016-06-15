require 'logger'

module Nexaas
  module Auditor
    class Configuration

      attr_accessor :enabled
      attr_accessor :logger
      attr_accessor :use_app_logging
      attr_accessor :use_staff_logging
      attr_accessor :use_app_statistics
      attr_accessor :use_staff_statistics
      attr_accessor :use_rails_statistics
      attr_accessor :statistics_namespace
      attr_accessor :statistics_service
      attr_accessor :stathat_settings

      def initialize
        @enabled = nil # set to true when configure is called
        @logger = nil
        @use_app_logging = false
        @use_staff_logging = false
        @use_app_statistics = false
        @use_staff_statistics = false
        @use_rails_statistics = false
        @statistics_namespace = nil
        @statistics_service = 'log' # or 'stathat'
        @stathat_settings = {key: nil}
      end

      # allow params to be read like a hash
      def [](option)
        send(option)
      end

      def logger
        @logger ||= ::Logger.new(STDERR)
      end

    end
  end
end
