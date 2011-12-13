require 'logger'

module Tom
  module Log

  # Allows you to define your own logger. Tom itself will
  # log things as .debug, so you can log with .info level
  # in your app and do stuff. Or you can use your own
  # logging altogether
  #
  # @param [Object] logger Some object that implements the
  #   .info .debug etc.
  #  @return [Object] The logger param
  def self.logger=(logger)
    @logger = logger
  end

  # Accessor for the current logger
  # @return [Object] See {Tom::Log.logger=}
  def self.logger
    unless @logger
      @logger = ::Logger.new(STDOUT)
      init_logger_defaults
    end
    @logger
  end

  # Takes the current {Tom::Log.logger} and sets its level
  # to {Logger::INFO} when you're in the development mode or
  # when ENV['BOBS'] is set.  Otherwise the log level is set
  # to {Logger::ERROR}.
  #
  # Also, the log format is changed to something short (hh:mm:ss)
  # @return [void]
  def self.init_logger_defaults
    if Goliath.env == :development || ENV['BOBS']
      Tom::Log.logger.level = Logger::INFO
    else
      @logger.level = ::Logger::ERROR
    end
    @logger.datetime_format = "%H:%M:%S:"
    Logger::Formatter.module_eval(
      %q{ def call(severity, time, progname, msg)} +
      %q{ "#{format_datetime(time)} #{msg2str(msg)}\n" end}
    )
    end
  end
end
