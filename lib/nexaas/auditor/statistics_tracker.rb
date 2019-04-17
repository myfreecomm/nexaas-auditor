module Nexaas
  module Auditor
    class StatisticsTracker
      VALID_SERVICES = %w[log stathat].freeze

      def self.setup(service, namespace = nil)
        unless VALID_SERVICES.include?(service)
          raise ArgumentError,
                "unknown statistics service '#{service}'"
        end
        tracker = if service == 'stathat'
                    key = Nexaas::Auditor.configuration.stathat_settings[:key]
                    StatisticsTrackers::Stathat.new(key, namespace)
                  else
                    logger = Nexaas::Auditor.configuration.logger
                    StatisticsTrackers::Log.new(logger, namespace)
                  end
        tracker
      end
    end
  end
end
