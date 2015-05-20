require "parslet"

module Syslog
  class Parser
    class InternalParser < Parslet::Parser
      def initialize(options={})
        super()

        @allow_missing_structured_data =
          options.fetch(:allow_missing_structured_data, false)
      end

      root :syslog_msg

      rule :syslog_msg do
        if @allow_missing_structured_data
          (header >> (sp >> structured_data).maybe >> (sp >> msg).maybe)
            .as(:syslog_msg)
        else
          (header >> sp >> structured_data >> (sp >> msg).maybe).as(:syslog_msg)
        end
      end

      rule :header do
        pri >> version >> sp >> timestamp >> sp >> hostname >> sp >>
          app_name >> sp >> procid >> sp >> msgid
      end

      rule :pri do
        str("<") >> prival >> str(">")
      end

      rule :prival do
        (digit.repeat(1, 3)).as(:prival) # range 0..191
      end

      rule :version do
        (nonzero_digit >> digit.repeat(0, 2)).as(:version)
      end

      rule :hostname do
        (nilvalue | printusascii.repeat(1, 255)).as(:hostname)
      end

      rule :app_name do
        (nilvalue | printusascii.repeat(1, 48)).as(:app_name)
      end

      rule :procid do
        (nilvalue | printusascii.repeat(1, 128)).as(:procid)
      end

      rule :msgid do
        (nilvalue | printusascii.repeat(1, 32)).as(:msgid)
      end

      rule :timestamp do
        (nilvalue | (full_date >> str("T") >> full_time)).as(:timestamp)
      end

      rule :full_date do
        date_fullyear >> str("-") >> date_month >> str("-") >> date_mday
      end

      rule :date_fullyear do
        digit.repeat(4, 4)
      end

      rule :date_month do
        digit.repeat(2, 2) # 01-12
      end

      rule :date_mday do
        digit.repeat(2, 2) # 01-28, 01-29, 01-30, 01-31 based on month/year
      end

      rule :full_time do
        partial_time >> time_offset
      end

      rule :partial_time do
        time_hour >> str(":") >> time_minute >> str(":") >> time_second >>
          time_secfrac.maybe
      end

      rule :time_hour do
        digit.repeat(2, 2) # 00-23
      end

      rule :time_minute do
        digit.repeat(2, 2) # 00-59
      end

      rule :time_second do
        digit.repeat(2, 2) # 00-59
      end

      rule :time_secfrac do
        str(".") >> digit.repeat(1, 6)
      end

      rule :time_offset do
        str("Z") | time_numoffset
      end

      rule :time_numoffset do
        (str("+") | str("-")) >> time_hour >> str(":") >> time_minute
      end

      rule :structured_data do
        (nilvalue | sd_element.repeat(1)).as(:structured_data)
      end

      rule :sd_element do
        str("[") >> sd_id >> sd_params >> str("]")
      end

      rule :sd_params do
        (sp >> sd_param).repeat.as(:sd_params)
      end

      rule :sd_param do
        param_name >> str("=") >> str('"') >> param_value >> str('"')
      end

      rule :sd_id do
        sd_name.as(:sd_id)
      end

      rule :param_name do
        sd_name.as(:param_name)
      end

      rule :param_value do
        # characters '"', '\' and ']' MUST be escaped
        (esc_seq | char).repeat.as(:param_value)
      end

      rule :esc_seq do
        str("\\") >> match(/[\]"]/).as(:esq_char)
      end

      rule :char do
        match(/[\]"]/).absent? >> any.as(:char)
      end

      rule :sd_name do
        # except '=', ' ', ']', '"'
        (match(/[= \]"]/).absent? >> printusascii).repeat(1, 32)
      end

      rule :msg do
        (any.repeat).as(:msg)
      end

      rule :sp do
        str(" ")
      end

      rule :printusascii do
        match(/[!-~]/)
      end

      rule :nonzero_digit do
        match(/[1-9]/)
      end

      rule :digit do
        str("0") | nonzero_digit
      end

      rule :nilvalue do
        str("-").as(:nilvalue)
      end
    end
  end
end
