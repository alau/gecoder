#!/usr/bin/perl
#
#  Main authors:
#     Christian Schulte <schulte@gecode.org>
#
#  Copyright:
#     Christian Schulte, 2005
#
#  Last modified:
#     $Date: 2005-07-17 15:55:06 +0200 (Sun, 17 Jul 2005) $ by $Author: schulte $
#     $Revision: 1953 $
#
#  This file is part of Gecode, the generic constraint
#  development environment:
#     http://www.gecode.org
#
#  See the file "LICENSE" for information on usage and
#  redistribution of this file, and for a
#     DISCLAIMER OF ALL WARRANTIES.
#
#

# 
# Print revision of file
#

while ($l = <>) {
  if ($l =~ /Revision: ([0-9\.]*) /) {
    print "Revision: $1\n";
    exit 0;
  }
}
