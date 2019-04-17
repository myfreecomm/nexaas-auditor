module Nexaas
  module Auditor
    class LogsSubscriber < Subscriber
      def logger
        Nexaas::Auditor.logger
      end

      private

      def event_method_name(name)
        "log_event_#{name.downcase.tr('.', '_')}"
      end
    end
  end
end
