module Nexaas
  module Auditor
    class StatsSubscriber < Subscriber
      def tracker
        Nexaas::Auditor.tracker
      end

      private

      def event_method_name(name)
        "track_event_#{name.downcase.tr('.', '_')}"
      end
    end
  end
end
