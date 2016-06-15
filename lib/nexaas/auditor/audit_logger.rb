module Nexaas
  module Auditor
    class AuditLogger

      VALID_LEVELS = %w(degug info warn error fatal)

      def initialize
        @logger = Nexaas::Auditor.configuration.logger
      end

      def log(options={})
        level = options.delete(:level)
        raise ArgumentError, "required key `:level` not found" if level.nil?
        raise ArgumentError, "key `:level` is invalid: '#{level}'" unless VALID_LEVELS.include?(level.to_s)
        safe_call { @logger.send(level, to_message(options)) }
      end

      def to_message(options)
        # TODO move this logic to a dedicated class
        check_message!(options)
        options.inject(['audit_log=true']) do |array, (key,value)|
          value = value.respond_to?(:iso8601) ? value.iso8601 : value
          array << "#{key}=#{value.to_s.strip.gsub(/\s/, '-')}"
          array
        end.join(' ')
      end

      def safe_call(&block)
        begin
          yield
        rescue => exception
          @logger.fatal("role=audit_logger class=#{self.class} measure=errors.unable_to_log exception=#{exception.class}")
        end
      end

      def check_message!(options)
        measure = options[:measure] || options['measure']
        raise ArgumentError, "required key 'measure' not found or empty" if measure.to_s == ''
      end

    end
  end
end
