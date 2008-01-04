require 'pathname'

# Set up some important locations.
CONFIG_FILE = Pathname.new("#{File.dirname(__FILE__)}/configure").realpath

# Delegate to Gecode's configure file.
File.chmod 0755, CONFIG_FILE
`#{CONFIG_FILE} --disable-examples`
