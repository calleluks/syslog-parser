# Syslog::Parser

Parse RFC5424 Syslog messages

## Installation

Add this line to your application's Gemfile:

```ruby
gem "syslog-parser"
```

And then execute:

```sh
bundle
```

Or install it using gem(1):

```sh
gem install syslog-parser
```

## Usage

```ruby
require "syslog/parser"

parser = Syslog::Parser.new

line = '<165>1 2003-10-11T22:14:15.003Z mymachine.example.com evntslog - ID47 '\
  [exampleSDID@32473 iut="3" eventSource="Application" eventID="1011"] '\
  'An application event log entry...'

message = parser.parse(line)

message.prival          #=> 165
message.facility        #=> 20
message.severity        #=> 5
message.version         #=> 1
message.timestamp       #=> 2003-10-11 22:14:15 UTC
message.timestamp.class #=> Time
message.hostname        #=> "mymachine.example.com"
message.app_name        #=> "evntslog"
message.procid          #=> nil
message.structured_data #=> [#<struct StructuredDataElement
# id="exampleSDID@32473"@71, params={"iut"=>"3", "eventSource"=>"Application",
# "eventID"=>"1011"}>]
message.msg             #=> "An application event log entry..."

parser.parse("malformed") #=> "Syslog::Parser::Error: Failed to match sequence
# (HEADER SP STRUCTURED_DATA (SP MSG)?) at line 1 char 1."
```

### Parsing messages received via Heroku HTTPS log drains

The cloud application platform [Heroku][heroku] allows it's users to register
log drains that receive Syslog formatted application log messages over HTTPS. As
outlined in [Heroku's documentation on HTTPS Log Drains][drains], these messages
do not fully conform to RFC5424:

> “application/logplex-1” does not conform to RFC5424. It leaves out
> STRUCTURED-DATA but does not replace it with a NILVALUE.

RFC5424 requires STRUCTURED-DATA to consist of either one NILVALUE or one or
more SD-ELEMENTs.

[heroku]: https://heroku.com
[drains]: https://devcenter.heroku.com/articles/log-drains#https-drains

In order to support parsing log messages received via Heroku HTTPS log drains,
the parser support an option that can be used to allow missing STRUCTURED-DATA:

```ruby
parser = Syslog::Parser.new(allow_missing_structured_data: true)

line = "<40>1 2012-11-30T06:45:29+00:00 host app web.3 - State changed from "\
  "starting to up"

message = parser.parse(line)

message.prival          #=> 40
message.facility        #=> 5
message.severity        #=> 0
message.version         #=> 1
message.timestamp       #=> 2012-11-30 06:45:29 UTC
message.hostname        #=> "host"
message.app_name        #=> "app"
message.procid          #=> "web.3"
message.structured_data #=> nil
message.msg             #=> "State changed from starting to up"
```
