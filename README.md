<div align="center">
  <a href="https://piotrmurach.github.io/tty" target="_blank"><img width="130" src="https://cdn.rawgit.com/piotrmurach/tty/master/images/tty.png" alt="tty logo" /></a>
</div>

# TTY::Logger

[![Gem Version](https://badge.fury.io/rb/tty-logger.svg)][gem]
[![Build Status](https://secure.travis-ci.org/piotrmurach/tty-logger.svg?branch=master)][travis]
[![Build status](https://ci.appveyor.com/api/projects/status/vtrkdk0naknnxoog?svg=true)][appveyor]
[![Code Climate](https://codeclimate.com/github/piotrmurach/tty-logger/badges/gpa.svg)][codeclimate]
[![Coverage Status](https://coveralls.io/repos/github/piotrmurach/tty-logger/badge.svg)][coverage]
[![Inline docs](http://inch-ci.org/github/piotrmurach/tty-logger.svg?branch=master)][inchpages]

[gitter]: https://gitter.im/piotrmurach/tty
[gem]: http://badge.fury.io/rb/tty-logger
[travis]: http://travis-ci.org/piotrmurach/tty-logger
[appveyor]: https://ci.appveyor.com/project/piotrmurach/tty-logger
[codeclimate]: https://codeclimate.com/github/piotrmurach/tty-logger
[coverage]: https://coveralls.io/github/piotrmurach/tty-logger
[inchpages]: http://inch-ci.org/github/piotrmurach/tty-logger

> A readable, structured and beautiful logging for the terminal

**TTY::Logger** provides independent logging component for [TTY toolkit](https://github.com/piotrmurach/tty).

## Features

* Intuitive console output for an increased readability
* Supports structured data logging
* Formats and truncates messages to avoid clogging logging output
* Includes metadata information: time, location, scope

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tty-logger'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tty-logger


## Contents

* [1. Usage](#1-usage)
* [2. Synopsis](#2-synopsis)
  * [2.1 Types](#21-types)
  * [2.2 Levels](#22-levels)
  * [2.3 Structured Data](#23-structured-data)
  * [2.4 Configuration](#24-configuration)
    * [2.4.1 Metadata](#241-metadata)
  * [2.5 Handlers](#25-handlers)
    * [2.5.1 Console Handler](#251-console-handler)
    * [2.5.2 Custom Handler](#252-custom-handler)
  * [2.6 Formatters](#26-formatters)

## 1. Usage

Create logger:

```ruby
logger = TTY::Logger.new
```

And log information using any of the logger [types](#21-types):

```ruby
logger.info "Deployed successfully"
logger.info "Deployed", "successfully"
logger.info { "Dynamically generated info" }
```

Include structured data:

```ruby
logger.info "Deployed successfully", myapp: "myapp", env: "prod"
# =>
# ✔ success Deployed successfully     app=myapp env=prod
```

Add [metadata](#241-metadata) information:

```ruby
logger = TTY::Logger.new do |config|
  config.metadata = [:date, :time]
end
logger.info "Deployed successfully"
# =>
# [2019-07-17] [23:21:55.287] › ℹ info    Info about the deploy     app=myapp env=prod
```

Or change structured data [formatting](#26-formatters):

```ruby
logger = TTY::Logger.new do |config|
  config.formatter = :json
end
logger.info "Deployed successfully"
# =>
# [2019-07-17] [23:21:55.287] › ℹ info    Info about the deploy     {"app":"myapp","env":"prod"}
```

## 2. Synopsis

## 2.1 Types

There are many logger types to choose from:

* `debug` - logs message at `:debug` level
* `info` - logs message at `:info` level
* `success` - logs message at `:info` level
* `wait` - logs message at `:info` level
* `warn` - logs message at `:warn` level
* `error` - logs message at `:error` level
* `fatal` - logs message at `:fatal` level

```ruby
logger.success "Deployed successfully"
# =>
# ✔ success Deployed successfully     app=myapp env=prod
```

### 2.2 Levels

The supported levels, ordered by precedence, are:

* `:debug` - for debug-related messages
* `:info` - for information of any kind
* `:warn` - for warnings
* `:error` - for errors
* `:fatal` - for fatal conditions

So the order is: `:debug` < `:info` < `:warn` < `:error` < `:fatal`

For example, `:info` takes precedence over `:debug`. If your log level is set to `:info`, `:info`, `:warn`, `:error` and `:fatal` will be printed to the console. If your log level is set to `:warn`, only `:warn`, `:error` and `:fatal` will be printed.

You can set level using the following:

```ruby
TTY::Logger.new level: :info
TTY::Logger.new level: "INFO"
TTY::Logger.new level: TTY::Logger::INFO_LEVEL
```

### 2.3 Structured data

To add global data available for all logger calls:

```ruby
logger = TTY::Logger.new(fields: {app: "myapp", env: "prod"})

logger.info("Deploying...")
# =>
# ℹ info    Deploying...              app=myapp env=prod
```

To only add data for a single log event:

```ruby
logger = TTY::Logger.new
logger.wait "Ready to deploy", app: "myapp", env: "prod"
# =>
# … waiting Ready to deploy           app=myapp env=prod
```

### 2.4 Configuration

All the configuration options can be changed globally via `configure` or per logger instance via object initialization.

* `:formatter` - the formatter used to display structured data. Defaults to `:text`. see [Formatters](#26-formatters) for more details.
* `:handlers` - the handlers used to log messages. Defaults to `[:console]`. See [Handlers](#25-handlers) for more details.
* `:level` - the logging level. Any message logged below this level will be simply ignored. Each handler may have it's own default level. Defaults to `:info`
* `:max_bytes` - the maximum message size to be logged in bytes. Defaults to `8192` bytes. The truncated message will have `...` at the end.
* `:max_depth` - the maximum depth for nested structured data. Defaults to `3`.
* `:metadata` - the meta info to display before the message, can be `:date`, `:time` or `:file`. Defaults to empty array `[]`, no metadata. Setting this to `:all` will print all the metadata.

For example, to configure `:max_bytes`, `:level` and `:metadata` for all logger instances do:

```ruby
TTY::Logger.configure do |config|
  config.max_bytes = 2**10
  config.level = :error
  config.metadata = [:time, :date]
end
```

Or if you wish to setup configuration per logger instance use block:

```ruby
logger = TTY::Logger.new do |config|
  config.max_bytes = 2**20
  config.metadata = [:all]
end
```

### 2.4.1 Metadata

The `:metdata` configuration option can include the following symbols:

* `:date` - the log event date
* `:time` - the log event time
* `:file` - the file with a line number the log event is triggered from


### 2.5 Handlers

`TTY::Logger` supports many ways to handle log messages.

The available handlers by default are:

* `:console` - log messages to the console, enabled by default
* `:null` - discards any log messages

You can also implement your own [custom handler](#252-custom-handler).

The handlers can be configured via global or instance configuration with `handlers`. The handler can be a name or a class name:

```ruby
TTY::Logger.new do |config|
  config.handlers = [:console]
end
```

Or using class name:

```ruby
TTY::Logger.new do |config|
  config.handlers = [TTY::Logger::Handlers::Console]
end
```

Handlers can also be added/removed dynamically through `add_handler` or `remove_handler`.

```ruby
logger = TTY::Logger.new
logger.add_handler(:console)
logger.remove_handler(:console)
```

#### 2.5.1 Console handler

The console handler prints log messages to the console. It supports the following options:

* `:styles` - a hash of styling options.
* `:formatter` - the formatter for log messages. Defaults to `:text`
* `:output` - the device to log error messages to. Defaults to `$stderr`

The supported options in the `:styles` are:

* `:label` - the name for the log message.
* `:symbol` - the graphics to display before the log message label.
* `:color` - the color for the log message.
* `:levelpad` - the extra amount of padding used to display log label.

See the [TTY::Logger::Handlers::Console]() for full list of styles.

Console handler has many defaults styles such as `success` and `error`:

```ruby
logger = TTY::Logger.new
logger.success("Default success")
logger.error("Default error")
```

You can change console handler default style with a tuple of handler name and options hash:

```ruby
handler = [
  :console, {
  styles: {
    success: {
      symbol: "+",
      label: "Ohh yes"
    },
    error: {
      symbol: "!",
      label: "Dooh",
      levelpad: 3
    }
  }
}]
```

And then use the `handlers` configuration option:

```ruby
new_style = TTY::Logger.new do |config|
  config.handlers = [handler]
end

new_style.success("Custom success")
new_style.error("Custom error")
```

#### 2.5.2 Custom handler

```ruby
class MyConsoleLogger
  def call(event)
    ...
  end
end
```

### 2.6 Formatters

The available formatters are:

* `:json`
* `:text`

You can configure format for all the handlers:

```ruby
TTY::Logger.new do |config|
  config.formatter = :json
end
```

Or specify a different formatter for each handler. For example, let's say you want to log to console twice, once with default formatter and once with `:json` formatter:

```ruby
TTY::Logger.new do |config|
  config.handlers = [:console, [:console, formatter: :json]]
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/piotrmurach/tty-logger. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the TTY::Logger project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/piotrmurach/tty-logger/blob/master/CODE_OF_CONDUCT.md).

## Copyright

Copyright (c) 2019 Piotr Murach. See LICENSE for further details.
