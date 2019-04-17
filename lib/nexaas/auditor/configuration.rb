require 'logger'

module Nexaas
  module Auditor
    class Configuration
      attr_accessor :enabled
      attr_accessor :logger

      attr_accessor :log_app_events
      attr_accessor :track_app_events
      attr_accessor :track_rails_events

      attr_accessor :statistics_namespace
      attr_accessor :statistics_service

      attr_accessor :stathat_settings

      def initialize
        @enabled = nil # set to true when configure is called
        @logger = nil
        @log_app_events = false
        @track_app_events = false
        @track_rails_events = false
        @statistics_namespace = nil
        @statistics_service = 'log' # or 'stathat'
        @stathat_settings = { key: nil }
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
