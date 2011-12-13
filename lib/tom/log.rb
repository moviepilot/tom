require 'logger'

module Tom
  module Log


  def self.logger=(logger)
    @logger = logger
  end

  def self.logger
    unless @logger
      @logger = ::Logger.new(STDOUT)
      init_logger_defaults
    end
    @logger
  end

  def self.init_logger_defaults
    @logger.level = ::Logger::ERROR
    @logger.datetime_format = "%H:%M:%S:"
    Logger::Formatter.module_eval(
      %q{ def call(severity, time, progname, msg)} +
      %q{ "#{format_datetime(time)} #{msg2str(msg)}\n" end}
    )
    end
  end
end
