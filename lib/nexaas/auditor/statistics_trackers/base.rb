module Nexaas
  module Auditor
    module StatisticsTrackers
      class Base
        def track_count(metric:, value: nil)
          value ||= 1
          track(:count, metric, value)
        end

        def track_value(metric:, value:)
          track(:value, metric, value)
        end

        private

        def track(type, name, value)
          validate_value!(value, type)
          full_name = full_metric_name(name)
          validate_name!(name, full_name)

          safe_call { send_track(type, full_name, value) }
        end

        def send_track(_type, _full_name, _value)
          raise "Not Implemented, override in subclass."
        end

        def full_metric_name(name)
          if @namespace.to_s == ''
            name
          else
            "#{@namespace}.#{name}"
          end
        end

        # allowed chars: a-z, A-Z, `.`, `-` and `_`
        def validate_name!(name, full_name)
          return unless (name.to_s == '') || full_name !~ /\A[a-zA-Z0-9\.\-_]+\Z/

          raise ArgumentError, "unsupported metric name: '#{name}'"
        end

        # allowed values: Numeric (Integer, Float, Decimal, etc)
        def validate_value!(value, _type)
          raise ArgumentError, "unsupported value: #{value} (#{value.class})" unless value.is_a?(Numeric)
        end

        def safe_call(&block)
          yield(block)
        rescue StandardError => exception
          logger.fatal("role=nexaas-auditor class=#{self.class} "\
                       "measure=errors.unable_to_track exception=#{exception.class}")
        end
      end
    end
  end
end
