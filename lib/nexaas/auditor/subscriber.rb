require 'active_support/core_ext/class/subclasses'

module Nexaas
  module Auditor
    class Subscriber

      def self.subscribe_all
        validate_subclasses!
        subscribers = []
        subclasses.each do |klass|
          subscribers << klass.subscribe()
        end
        subscribers
      end

      def self.subscribe(options={})
        subscriber = options.fetch(:subscriber) { ::ActiveSupport::Notifications }
        subscriber.subscribe(pattern, new)
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

      # raise error if no app-level subclasses (of StatsSubscriber and
      # LogsSubscriber) are found.
      def self.validate_subclasses!
        raise RuntimeError,
          "no subclasses of #{self} found!" if subclasses.empty?
      end

    end
  end
end
