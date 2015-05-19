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
line = "<34>1 2003-10-11T22:14:15.003Z mymachine.example.com su - ID47 - "\
  "'su root' failed for lonvick on /dev/pts/8"

message = parser.parse(line)

message.prival          #=> 34
message.facility        #=> 4
message.severity        #=> 2
message.version         #=> 1
message.timestamp       #=> 2003-10-11 22:14:15 UTC
message.timestamp.class #=> Time
message.hostname        #=> "mymachine.example.com"
message.app_name        #=> "su"
message.procid          #=> nil
message.structured_data #=> nil
message.msg             #=> "'su root' failed for lonvick on /dev/pts/8"
```
