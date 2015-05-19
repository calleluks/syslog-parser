require "syslog/parser/internal_parser"
require "syslog/parser/transform"

module Syslog
  class Parser
    def initialize
      @transform = Transform.new
      @parser = InternalParser.new
    end

    def parse(line)
      @transform.apply @parser.parse(line)
    end
  end
end
