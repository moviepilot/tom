require_relative 'tom/log'
require_relative 'tom/routes'
require_relative 'tom/config'
require_relative 'init'

module Tom
  extend Tom::Config
  extend Tom::Routes

end
