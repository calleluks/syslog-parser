require "parslet"
require "syslog/parser/message"
require "time"

module Syslog
  class Parser
    class Transform < Parslet::Transform
      rule nilvalue: simple(:nilvalue) do
        nil
      end

      rule(
        prival: simple(:prival),
        version: simple(:version),
        timestamp: simple(:timestamp),
        hostname: simple(:hostname),
        app_name: simple(:app_name),
        procid: simple(:procid),
        msgid: simple(:msgid),
        structured_data: simple(:structured_data),
        msg: simple(:msg),
      ) do
        Message.new(
          Integer(prival),
          Integer(version),
          Time.parse(timestamp),
          hostname,
          app_name,
          procid,
          msgid,
          structured_data,
          msg,
        )
      end
    end
  end
end
