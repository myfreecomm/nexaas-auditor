# Nexaas::Auditor

[![Build Status](https://travis-ci.org/myfreecomm/nexaas-auditor.svg?branch=master)](https://travis-ci.org/myfreecomm/nexaas-auditor)
[![Test Coverage](https://codeclimate.com/github/myfreecomm/nexaas-auditor/badges/coverage.svg)](https://codeclimate.com/github/myfreecomm/nexaas-auditor/coverage)
[![Code Climate](https://codeclimate.com/github/myfreecomm/nexaas-auditor/badges/gpa.svg)](https://codeclimate.com/github/myfreecomm/nexaas-auditor)

Common **opinionated** code for audit logs and statistics tracking for Rails apps, via [ActiveSupport instrumentation](http://edgeguides.rubyonrails.org/active_support_instrumentation.html). Used in production in a few [Nexaas](http://www.nexaas.com) systems.

This has been tested with Rails 4.2.x and 5.2.x. We are not sure about Rails 3.x. It requires Ruby v2.2.3 at least (but we recommend using v2.3.x).

The audit log is created in a [logfmt](https://www.brandur.org/logfmt) format only for now. Support for more log formats is planned in the future.

Both the audit log and statistics tracking assume all instrumented events are named in a dot notation format, for example you could use `'app.users.login.sucess'` to instrument a successful user login event. The `'app.'` prefix is a suggestion to separate your business-logic events from framework-specific (Rails) events, which will always have a `'rails.'` prefix, for example `'rails.action_controller.runtime.total'` for example.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nexaas-auditor'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install nexaas-auditor
```

## Setup

In a Rails initializer file such as `config/initializers/nexaas_auditor.rb`, you can setup the gem:

```ruby
require 'nexaas/auditor'

Nexaas::Auditor.configure do |config|
  config.enabled = true
  # define what logger you will use
  config.logger = Rails.logger

  # use audit logging for business-logic instrumented events
  config.log_app_events = true

  # use statistics tracking for business-logic instrumented events
  config.track_app_events = true

  # use statistics tracking for default Rails instrumented events
  # don't forget to add the 'nunes' gem to your Gemfile (we use Nunes to do the
  # heavy lifting on the instrumented Rails events)
  config.track_rails_events = false

  # optionally, prepend statistics metric names with your app name. use this if
  # you use the same statistics service (ie StatHat) for multiple apps.
  config.statistics_namespace = 'myappname'

  # use StatHat service if you want to
  # don't forget to add the 'stathat' gem to your Gemfile
  # config.statistics_service = 'stathat'
  # config.stathat_settings = {key: 'stathat-ez-key'}

  # the 'log' service only writes the stats to the audit log instead of
  # sending them to an external service.
  config.statistics_service = 'log'
end

# we will be using the folder logger for the loggers
# and the folder statistics for the trackers 
# make sure all subscribers are loaded before subscribing below
Dir[Rails.root.join("app/loggers/*.rb")].each { |f| require f }

# if you added statistics tracking, you need to require the statistics folder too
Dir[Rails.root.join("app/statistics/*.rb")].each { |f| require f }

# setup all subscribers
Nexaas::Auditor.subscribe_all
```

## Logger

Then, create your loggers in `app/loggers/` for example, inheriting from `Nexaas::Auditor::LogsSubscriber`.

For example:

```ruby
class UsersAppLogger < ::Nexaas::Auditor::LogsSubscriber
  # The namespace for events to subscribe to. In this example, subscribe to all
  # events beginning with "app.users.".
  def self.pattern
    /\Aapp\.users\..+\Z/
  end

  # Called when an event with name == 'app.users.login.success' is received.
  #
  #   name = the event name, 'app.users.login.success' in this case
  #   start = the time the event started
  #   finish = the time the event finished
  #     (tip: finish - start gives you the duration in seconds as a float)
  #   event_id = an unique id for the event
  #   payload = a hash of extra data the event may have supplied when instrumented
  #
  def log_event_app_users_login_success(name, start, finish, event_id, payload)
    user_id = payload[:user_id]
    # Do the actual logging. The `:level` and `:measure` keys are required,
    # anything else will be transformed in a key=value pair in the log string.
    logger.log(level: :info, measure: name, user_id: user_id)
  end
end
```

## Tracker

To create your statistic trackers in `app/statistics/` for example, inheriting from `Nexaas::Auditor::StatsSubscriber`.
```ruby
class UsersAppStatsTracker < ::Nexaas::Auditor::StatsSubscriber
  # The namespace for events to subscribe to. In this example, subscribe to all
  # events beginning with "app.users.".
  def self.pattern
    /\Aapp\.users\..+\Z/
  end

  # Called when an event with name == 'app.users.login.success' is received.
  #
  #   name = the event name, 'app.users.login.success' in this case
  #   start = the time the event started
  #   finish = the time the event finished
  #     (tip: finish - start gives you the duration in seconds as a float)
  #   event_id = an unique id for the event
  #   payload = a hash of extra data the event may have supplied when instrumented
  #
  def track_event_app_users_login_success(name, start, finish, event_id, payload)
    user_id = payload[:user_id]

    # Do the actual statistic tracking.

    # Use the `count` type to track event occurrences or quantities. The `:metric`
    # key is required (generally use the name or append something to the name).
    # The `:value` should be an Integer. If `:value` is omitted it will be
    # assumed a value of 1.
    tracker.track_count(metric: name, value: 1)

    # Use the `value` type to track event durations or amounts. The `:metric`
    # key is required (generally use the name or append something to the name).
    # The `:value` key is also required and should be an Integer, Float or Decimal.
    duration = ((finish - start) * 1_000.0).round # to get the value in milliseconds
    tracker.track_value(metric: "#{name}.duration", value: duration)
  end
end
```

## Usage

Now all that is left for you is to instrument your code to fire the events above. Following the example of logging and tracking an user login, we might have this in a hypothetical `SessionsController` in your app:

```ruby
class SessionsController < ApplicationController
  def create
    @user = User.authenticate(session_params)
    if @user
      Nexaas::Auditor.instrument('app.users.login.success', user_id: @user.id)
      redirect_to root_path, success: "You are logged in!"
    else
      # do something else, show some error, etc
    end
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/myfreecomm/nexaas-auditor. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

There is a list of planned features and improvements on the [TODO.md](https://github.com/myfreecomm/nexaas-auditor/blob/master/TODO.md) file, please read it before anything else if you want to help with nexaas-auditor development.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
