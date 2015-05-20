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
