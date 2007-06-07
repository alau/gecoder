#!/usr/bin/ruby

require 'mkmf'
require 'pathname'

# Find the Gecode libraries.
find_library("gecodeint", "" )
find_library("gecodekernel", "")
find_library("gecodeminimodel", "")
find_library("gecodesearch", "")
find_library("gecodeset", "")

# Set up some important locations.
ROOT = Pathname.new(File.dirname(__FILE__) + '/..').realpath
RUST_INCLUDES = "#{ROOT}/vendor/rust/include"
BINDINGS_DIR = "#{ROOT}/lib/bindings" 
CPP_DIR = "#{ROOT}/src/cpp" 

cppflags = "-I#{RUST_INCLUDES} -I#{BINDINGS_DIR}"
with_cppflags(cppflags) {
	find_header("rust_conversions.hh", RUST_INCLUDES)
	find_header("rust_checks.hh", RUST_INCLUDES)
}

# Create the headers in the C++ source directory. Is there a less dirty way of 
# specifying where they should be placed?
Dir.chdir(CPP_DIR)
# The specification of the bindings
load "#{BINDINGS_DIR}/bindings.rb"

# Create the makefile.
create_makefile("Gecode")
