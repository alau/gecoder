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
BINDINGS_DIR = "#{ROOT}/lib/gecoder/bindings" 
EXT_DIR = "#{ROOT}/ext"
ORIGINAL_DIR = Pathname.new('.').realpath

cppflags = "-I#{RUST_INCLUDES} -I#{EXT_DIR}"
with_cppflags(cppflags) {
  find_header("rust_conversions.hh", RUST_INCLUDES)
  find_header("rust_checks.hh", RUST_INCLUDES)
}

# Load the specification of the bindings. This creates the headers in the 
# current directory.
load "#{BINDINGS_DIR}/bindings.rb"

# Create the makefile.
create_makefile("gecode")
