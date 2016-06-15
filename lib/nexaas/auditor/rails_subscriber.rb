module Nexaas
  module Auditor
    class RailsSubscriber

      def self.subscribe_all
        statistics_tracker = Nexaas::Auditor.tracker
        nunes_statistics_tracker = Nexaas::Auditor::Adapters::Nunes.new(statistics_tracker)
        ::Nunes.subscribe(nunes_statistics_tracker)
      end

    end
  end
end
