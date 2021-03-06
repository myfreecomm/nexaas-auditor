require 'nunes'

module Nexaas
  module Auditor
    module Adapters

      class Nunes < ::Nunes::Adapter

        attr_reader :client

        def initialize(client)
          @client = client
        end

        def increment(metric, value=1)
          client.track_count(metric: prepare(metric), value: value)
        end

        def timing(metric, value)
          client.track_value(metric: prepare(metric), value: value)
        end

        def prepare(metric, replacement = Separator)
          metric = "rails.#{metric}"
          super
        end
      end

    end
  end
end
