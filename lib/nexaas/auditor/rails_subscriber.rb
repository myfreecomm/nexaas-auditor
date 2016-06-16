module Nexaas
  module Auditor
    class RailsSubscriber

      def self.subscribe_all
        ::Nunes.subscribe(nunes_statistics_wrapper)
      end

      def self.nunes_statistics_wrapper
        Nexaas::Auditor::Adapters::Nunes.new(Nexaas::Auditor.tracker)
      end

    end
  end
end
