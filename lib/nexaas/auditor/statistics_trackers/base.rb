module Nexaas
  module Auditor
    module StatisticsTrackers
      class Base

        def track_count(name, value=nil)
          track(:count, name, value)
        end

        def track_value(name, value)
          track(:value, name, value)
        end

        private

        def track(type, name, value)
          value ||= 1 if type == :count
          validate_value!(value, type)
          full_name = full_metric_name(name)
          validate_name!(full_name)

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
        def validate_name!(name)
          raise ArgumentError, "unsuported metric name: '#{name}'" unless name =~ /\A[a-zA-Z0-9\.\-_]+\Z/
        end

        # allowed values: Numeric (Integer, Float, Decimal, etc)
        def validate_value!(value, type)
          raise ArgumentError, "unsuported value: #{value} (#{value.class})" unless value.is_a?(Numeric)
        end

      end
    end
  end
end