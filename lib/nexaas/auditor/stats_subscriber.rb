module Nexaas
  module Auditor
    class StatsSubscriber < Subscriber

      def tracker
        Nexaas::Auditor.tracker
      end

      private

      def event_method_name(name)
        "track_event_#{name.downcase.gsub('.', '_')}"
      end

    end
  end
end
