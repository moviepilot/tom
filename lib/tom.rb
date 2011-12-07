require_relative 'tom/log'
require_relative 'tom/routes'
require_relative 'tom/config'
require_relative 'init'

# The only thing you should really do with the Tom class is 
# setting or reading its configuration.
module Tom
  extend Tom::Config
end
