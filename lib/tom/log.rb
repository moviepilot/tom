require 'logger'

module Tom
  LOG = ::Logger.new(STDOUT)
  LOG.level = ::Logger::ERROR
  LOG.datetime_format = "%H:%M:%S:"
  Logger::Formatter.module_eval(
    %q{ def call(severity, time, progname, msg)} +
    %q{ "#{format_datetime(time)} #{msg2str(msg)}\n" end}
  )
end
