require 'active_support/notifications'

require 'nexaas/auditor/version'
require 'nexaas/auditor/configuration'
require 'nexaas/auditor/subscriber'
require 'nexaas/auditor/logs_subscriber'
require 'nexaas/auditor/stats_subscriber'
require 'nexaas/auditor/adapters/nunes'
require 'nexaas/auditor/rails_subscriber'
require 'nexaas/auditor/audit_logger'
require 'nexaas/auditor/statistics_trackers/base'
require 'nexaas/auditor/statistics_trackers/log'
require 'nexaas/auditor/statistics_trackers/stathat'
require 'nexaas/auditor/statistics_tracker'

module Nexaas
  module Auditor

    extend SingleForwardable
    # forwards Nexaas::Auditor.instrument to ActiveSupport::Notifications.instrument
    single_delegate :instrument => ActiveSupport::Notifications

    class << self

      def configure
        # if configuration.enabled has not been set yet (is still 'nil'), set to true.
        configuration.enabled = true if configuration.enabled.nil?
        yield(configuration)
      end

      def configuration
        @configuration ||= Configuration.new
      end

      def logger
        Thread.current[:_nexaas_auditor_logger] ||= AuditLogger.new
      end

      # def logger=(new_logger)
      #   Thread.current[:_nexaas_auditor_logger] = new_logger
      # end

      def tracker
        Thread.current[:_nexaas_auditor_tracker] ||= StatisticsTracker.setup(
          configuration.statistics_service,
          configuration.statistics_namespace
        )
      end

      # def tracker=(new_tracker)
      #   Thread.current[:_nexaas_auditor_tracker] = new_tracker
      # end

      def subscribe_all
        subscribers = []
        subscribers << LogsSubscriber.subscribe_all if configuration.log_app_events
        subscribers << StatsSubscriber.subscribe_all if configuration.track_app_events
        subscribers << RailsSubscriber.subscribe_all if configuration.track_rails_events
        subscribers
      end

    end

  end
end
