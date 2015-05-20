require "syslog/parser/internal_parser"
require "syslog/parser/transform"

module Syslog
  class Parser
    class Error < StandardError; end

    def initialize(options={})
      @transform = Transform.new
      @parser = InternalParser.new(options)
    end

    def parse(line)
      @transform.apply @parser.parse(line)
    rescue Parslet::ParseFailed => parse_failed
      raise Error, parse_failed.message
    end
  end
end
