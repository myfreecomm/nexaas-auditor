require 'nexaas/auditor/version'
require 'nexaas/auditor/configuration'

module Nexaas
  module Auditor

    class << self
      # Similar to configure below, but used only internally within the gem
      # to configure it without initializing any of the third party hooks
      def preconfigure
        yield(configuration)
      end

      def configure
        # if configuration.enabled has not been set yet (is still 'nil'), set to true.
        configuration.enabled = true if configuration.enabled.nil?
        yield(configuration)
      end

      def reconfigure
        @configuration = Configuration.new
        @configuration.enabled = true
        yield(configuration)
      end

      def unconfigure
        @configuration = nil
      end

      def configuration
        @configuration ||= Configuration.new
      end
    end

  end
end
