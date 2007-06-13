$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__))

# Bindings
require 'gecode.so'
module Gecode
  # The bindings are located in ::GecodeRaw, so we assign that to ::Gecode::Raw.
  # This is done because bindings/bindings.rb use ::GecodeRaw and appears to
  # have limitations that do not allow using a sub-namespace.
  Raw = ::GecodeRaw
end

# Interface
require 'interface/binding_changes'
require 'interface/model'