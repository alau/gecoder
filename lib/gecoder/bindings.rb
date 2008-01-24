module Gecode
  # Loads the binding libraries. This is done as a method in order to be easier
  # to test. 
  def self.load_bindings_lib #:nodoc:
    # Workaround to get the precompiled DLLs into the DLL search path on 
    # Windows.
    dll_dir = File.dirname(__FILE__) + '/../../vendor/gecode/win32/lib'
    if RUBY_PLATFORM =~ /mswin/ and File.exists? dll_dir
      # Switch directory while loading libraries so that the DLLs are in the 
      # work directory.
      require 'fileutils'
      FileUtils.cd dll_dir do
        require 'gecode'
      end
    else
      require 'gecode'
    end
  end  
  
  # Load the bindings library.
  load_bindings_lib  
  
  # The Gecode::Raw module is what the interface should use to access methods
  # in Gecode. The actual bindings are located in ::GecodeRaw.
  
  # Describes a layer that delegates to GecodeRaw only after having logged the 
  # call.
  module LoggingLayer #:nodoc:
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
  
  # We just make Gecode::Raw an alias of the real module.
  Raw = ::GecodeRaw
  # Log all calls via Gecode::Raw.
  #Raw = LoggingLayer
end
