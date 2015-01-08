Gecode/R
========

_**Warning - this is old stuff:** Gecode/R has been quite inactive since 2008.
Most of the code is old and depends on old versions of e.g. Ruby and Gecode._

Website: http://gecoder.org

Gecode/R is a Ruby interface to the Gecode constraint programming library.
Gecode/R is intended for people with no previous experience of constraint
programming, aiming to be easy to pick up and use.

See `Gecode::Mixin` to get started.

Installation
------------

Gecode/R requires Gecode 2.2.0, which can be downloaded from
http://www.gecode.org/download.html . See [the installation instructions](
http://www.gecode.org/doc/2.2.0/reference/PageComp.html)
for details on how to compile it.

Installing from gem
-------------------

There are two gems. The first includes only Gecode/R, and assumes that you have
installed Gecode yourself. The second includes both Gecode/R and Gecode. If you
use Windows then you're recommended to use the second one, even though you
already have Gecode, as the other one does not come in a pre-compiled variant.

Gecode/R only:

    gem install gecoder

Gecode/R and Gecode:

    gem install gecoder-with-gecode

### Installing from source using gem

    rake gem
    gem install pkg/gecoder-1.x.x.gem

### Installing from source without using gem

`gecode.so` might have another extension depending on which platform it's
generated on (replace the extension in the following commands with whatever
extension it's given).

    cd ext
    ruby extconf.rb
    make
    mv gecode.so ../lib/

### Running the tests

    rake specs

