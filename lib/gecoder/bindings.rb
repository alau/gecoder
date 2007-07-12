require 'gecode.so'
module Gecode
  # The Gecode::Raw module is what the interface should use to access methods
  # in Gecode. The actual bindings are located in ::GecodeRaw.
  
  # We just make Gecode::Raw an alias of the real module.
  Raw = ::GecodeRaw
  # Log all calls via Gecode::Raw.
  #Raw = ::LoggingLayer
  
  # Describes a layer that delegates to GecodeRaw only after having logged the 
  # call.
  module LoggingLayer
    require 'logger'
  
    def self.method_missing(name, *args)
      logger.info{ "#{name}(#{args.join(', ')})" }
      ::GecodeRaw.send(name, *args)
    end
    
    def self.const_missing(name)
      ::GecodeRaw.const_get(name)
    end
    
    # Gets the logger, or creates one if none exists.
    def self.logger
      return @logger unless @logger.nil?
      file = open('gecoder.log', File::WRONLY | File::APPEND | File::CREAT)
      @logger = ::Logger.new(file)
      @logger.datetime_format = "%Y-%m-%d %H:%M:%S"
      @logger
    end
  end
end
