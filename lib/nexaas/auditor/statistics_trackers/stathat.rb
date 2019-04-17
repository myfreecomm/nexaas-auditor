module Nexaas
  module Auditor
    module StatisticsTrackers
      class Stathat < Base
        attr_reader :logger

        def initialize(key, namespace = nil)
          @key = key.to_s
          @namespace = namespace.to_s
          @logger = Nexaas::Auditor.configuration.logger
          require 'stathat' if Nexaas::Auditor.configuration.statistics_service == 'stathat'
          raise ArgumentError, "required Stathat EZ Key not found" if @key == ''
        end

        private

        # Regex to determine if the current process is a short lived kind of
        # script.
        SHORT_RUNNING_PROCESS_NAMES_REGEX = /sidekiq|resque|delayed|rspec|rake/i.freeze

        def short_running_process?
          $0 =~ SHORT_RUNNING_PROCESS_NAMES_REGEX
        end

        def send_track(type, full_name, value)
          # the default StatHat::API Ruby methods are asynchronous. If you are
          # using this gem in a script that is short-lived, you can use
          # StatHat::SyncAPI to make synchronous calls to StatHat.
          klass = (short_running_process? ? ::StatHat::SyncAPI : ::StatHat::API)

          logger.debug("[#{self.class}] calling #{klass}.ez_post_#{type}('#{full_name}', '#{@key}', #{value})")
          klass.send("ez_post_#{type}", full_name, @key, value)
        end
      end
    end
  end
end
