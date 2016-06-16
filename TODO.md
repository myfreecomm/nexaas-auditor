## TODO

Tasks yet to be done, in order of importance. Feel free to help out ;-)

- Get test coverage to 100%
- Setup Travis.CI integration
- Setup CodeClimate integration
- Only require [Nunes](https://github.com/jnunemaker/nunes) gem if the configuration says `track_rails_events = true`, and "fail fast" if `Nunes` is not loaded
- Only require [StatHat](https://github.com/patrickxb/stathat) gem if the configuration says `statistics_service = 'stathat'`, and "fail fast" if `StatHat` is not loaded
- Extract log formating logic out of Nexaas::Auditor::AuditLogger into a proper log formating class
- Add possibility of supporting more log formats (currently only logfmt format is supported)
- Add options to limit the metrics subscribed by default when `track_rails_events = true`; by default [Nunes](https://github.com/jnunemaker/nunes) sends **a lot** of metrics, some of them may not be so useful and end up "polluting" the statistics service (or, more importantly, cost unnecessary money if the service restricts the number of metrics created)
- Add more statistic services support ([Instrumental](https://instrumentalapp.com/), [self-hosted StatsD](https://github.com/etsy/statsd), [Librato](https://www.librato.com/), [DataDoc](https://www.datadoghq.com/), etc)
