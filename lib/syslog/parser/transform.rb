require "parslet"
require "syslog/parser/message"
require "syslog/parser/structured_data_element"
require "time"

module Syslog
  class Parser
    class Transform < Parslet::Transform
      rule(nilvalue: simple(:nilvalue)) { nil }
      rule(char: simple(:char)) { char.to_s }
      rule(esq_char: simple(:esq_char)) { esq_char.to_s }

      rule sd_id: simple(:sd_id), sd_params: subtree(:sd_params) do
        params = sd_params.inject({}) do |params, sd_param|
          params.merge!(
            sd_param.fetch(:param_name).to_s =>
              sd_param.fetch(:param_value).join,
          )
        end
        StructuredDataElement.new(sd_id, params)
      end

      rule syslog_msg: subtree(:syslog_msg) do
        Message.new(
          Integer(syslog_msg[:prival]),
          Integer(syslog_msg[:version]),
          Time.parse(syslog_msg[:timestamp]),
          syslog_msg[:hostname],
          syslog_msg[:app_name],
          syslog_msg[:procid],
          syslog_msg[:msgid],
          syslog_msg[:structured_data],
          syslog_msg[:msg],
        )
      end
    end
  end
end
