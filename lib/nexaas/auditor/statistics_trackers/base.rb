module Nexaas
  module Auditor
    module StatisticsTrackers
      class Base

        def track_count(name, value=nil)
          value ||= 1
          track(:count, name, value)
        end

        def track_value(name, value)
          track(:value, name, value)
        end

        private

        def track(type, name, value)
          validate_value!(value, type)
          full_name = full_metric_name(name)
          validate_name!(name, full_name)

          send_track(type, full_name, value)
        end

        def send_track(type, full_name, value)
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
          if (name.to_s == '') || !(full_name =~ /\A[a-zA-Z0-9\.\-_]+\Z/)
            raise ArgumentError, "unsuported metric name: '#{name}'"
          end
        end

        # allowed values: Numeric (Integer, Float, Decimal, etc)
        def validate_value!(value, type)
          raise ArgumentError, "unsuported value: #{value} (#{value.class})" unless value.is_a?(Numeric)
        end

      end
    end
  end
end
