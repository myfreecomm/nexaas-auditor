# Nexaas::Auditor

[![Build Status](https://travis-ci.org/myfreecomm/nexaas-auditor.svg?branch=master)](https://travis-ci.org/myfreecomm/nexaas-auditor)

Common **opnionated** code for audit logs and statistcs tracking for Rails apps, via [ActiveSupport instrumentation](http://edgeguides.rubyonrails.org/active_support_instrumentation.html). Used in production in a few [Nexaas](http://www.nexaas.com) systems.

This has been tested with Rails 4.2.x only so far. It probably works fine as well in Rails 4.1.x, but I'm not sure about Rails 3.x yet. It requires Ruby v2.2.3 at least (but we recommend using v2.3.x).

The audit log is created in a [logfmt](https://www.brandur.org/logfmt) format only for now. Support for more log formats is planned in the future.

Both the audit log and statistics tracking assume all instrumented events are named in a dot notation format, for example you could use `'app.users.login.sucess'` to instrument a successful user login event. The `'app.'` prefix is a suggestion to separate your bussiness-logic events from framework-specific (Rails) events, which will always have a `'rails.'` prefix, for example `'rails.action_controller.runtime.total'` for example.

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

## Usage

In a Rails initializer file such as `config/initializers/nexaas_auditor.rb`, put something like this:

```ruby
require 'nexaas/auditor'

Nexaas::Auditor.configure do |config|
  config.enabled = true
  config.logger = Rails.logger

  # use audit logging for bussiness-logic instrumented events
  config.log_app_events = true

  # use statistics tracking for bussiness-logic instrumented events
  config.track_app_events = true

  # use statistics tracking for default Rails instrumented events
  # don't forget to add the 'nunes' gem to your Gemfile (we use Nunes to do the
  # heavy lifting on the instrumented Rails events)
  config.track_rails_events = true

  # optionally, prepend statistics metric names with your app name. use this if
  # you use the same statistics service (ie StatHat) for multiple apps.
  config.statistics_namespace = 'myappname'

  if Rails.env.production?
    # use StatHat service in production only
    # don't forget to add the 'stathat' gem to your Gemfile
    config.statistics_service = 'stathat'
    config.stathat_settings = {key: 'stathat-ez-key'}
  else
    # the 'log' service only writes the stats to the audit log instead of
    # sending them to an external service.
    config.statistics_service = 'log'
  end
end

# setup all subscribers
Nexaas::Auditor.subscribe_all
```

Then, create your loggers and statistic trackers in `app/loggers/` and `app/statistics/` for example, inheriting from `Nexaas::Auditor::LogSubscriber` and `Nexaas::Auditor::StatsSubscriber` respectively.

For example:

```ruby
class UsersAppLogger < ::Nexaas::Auditor::LogSubscriber
  # The namespace for events to subscribe to. In this example, subscribe to all
  # events beggining with "app.users.".
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
    # Do the actual loggging. The `:level` and `:measure` keys are required,
    # anything else will be transformed in a key=value pair in the log string.
    logger.log(level: :info, measure: name, user_id: user_id)
  end
end

class UsersAppStatsTracker < ::Nexaas::Auditor::StatsSubscriber
  # The namespace for events to subscribe to. In this example, subscribe to all
  # events beggining with "app.users.".
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

    # Use the `count` type to track event occurences or quantities. The `:metric`
    # key is required (generally use the name or append something to the name).
    # The `:value` should be an Integer. If `:value` is ommited it will be
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

Now all that is left is for you to instrument your code to fire the events above. Following the example of logging and tracking user logins, we might have this in a hipothetical `SessionsController` in your app:

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
