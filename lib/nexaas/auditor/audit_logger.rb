module Nexaas
  module Auditor
    class AuditLogger
      VALID_LEVELS = %w[degug info warn error fatal].freeze

      attr_accessor :logger

      def initialize(logger = nil)
        @logger = logger
      end

      def logger
        @logger ||= Nexaas::Auditor.configuration.logger
      end

      def log(options = {})
        level = options.delete(:level)
        raise ArgumentError, "required key `:level` not found" if level.nil?
        raise ArgumentError, "key `:level` is invalid: '#{level}'" unless VALID_LEVELS.include?(level.to_s)

        check_message!(options)
        safe_call { logger.send(level, to_message(options)) }
      end

      private

      def to_message(options)
        # TODO: move this logic to a dedicated class and add more tests
        options.each_with_object(['audit_log=true']) do |(key, value), array|
          value = value.respond_to?(:iso8601) ? value.iso8601 : value
          array << "#{key}=#{value.to_s.strip.gsub(/\s/, '-')}"
        end.join(' ')
      end

      def safe_call(&block)
        yield(block)
      rescue StandardError => exception
        logger.fatal("role=audit_logger class=#{self.class} measure=errors.unable_to_log exception=#{exception.class}")
      end

      def check_message!(options)
        measure = options[:measure] || options['measure']
        raise ArgumentError, "required key 'measure' not found or empty" if measure.to_s == ''
      end
    end
  end
end
