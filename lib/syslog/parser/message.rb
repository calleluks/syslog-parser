Message = Struct.new(
  :prival,
  :version,
  :timestamp,
  :hostname,
  :app_name,
  :procid,
  :msgid,
  :structured_data,
  :msg,
) do
  def facility
    @facility ||= prival / 8
  end

  def severity
    @severity ||= prival - facility * 8
  end
end
