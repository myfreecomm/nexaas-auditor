module Nexaas
  module Auditor
    class StatisticsTracker

      VALID_SERVICES = %w(log stathat)

      def self.setup(service, namespace=nil)
        raise ArgumentError,
          "unknown statistics service '#{service}'" unless VALID_SERVICES.include?(service)
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
