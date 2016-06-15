module Nexaas
  module Auditor
    module StatisticsTrackers
      class Log < Base

        def initialize(logger, namespace=nil)
          @logger = logger || Nexaas::Auditor.configuration.logger
          @namespace = namespace.to_s
        end

        private

        def send_track(type, full_name, value)
          @logger.info("[#{self.class}] type=#{type} metric=#{full_name} value=#{value}")
        end

      end
    end
  end
end
