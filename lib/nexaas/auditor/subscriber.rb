module Nexaas
  module Auditor
    class Subscriber

      def self.subscribe_all
        subscribers = []
        subclasses.each do |klass|
          subscribers << klass.subscribe()
        end
        subscribers
      end

      def self.subscribe(options={})
        subscriber = options.fetch(:subscriber) { ::ActiveSupport::Notifications }
        subscriber.subscribe pattern, new
      end

      def self.pattern
        raise "Not Implemented, override in subclass and provide a regex or string."
      end

      # Dispatcher that converts incoming events to method calls.
      def call(name, start, finish, event_id, payload)
        method_name = event_method_name(name)
        if respond_to?(method_name)
          send(method_name, name, start, finish, event_id, payload)
        end
      end

      private

      def event_method_name(name)
        raise "Not Implemented, override in subclass."
      end

    end
  end
end
