/*
 *  Main authors:
 *     Christian Schulte <schulte@gecode.org>
 *
 *  Copyright:
 *     Christian Schulte, 2005
 *
 *  Last modified:
 *     $Date: 2006-08-04 16:07:12 +0200 (Fri, 04 Aug 2006) $ by $Author: schulte $
 *     $Revision: 3518 $
 *
 *  This file is part of Gecode, the generic constraint
 *  development environment:
 *     http://www.gecode.org
 *
 *  See the file "LICENSE" for information on usage and
 *  redistribution of this file, and for a
 *     DISCLAIMER OF ALL WARRANTIES.
 *
 */

#include "test/int.hh"
#include "test/log.hh"

#include <cmath>
#include <algorithm>

static IntSet s(-3,3);

class Basic : public IntTest {
public:
  Basic(void)
    : IntTest("Basic",3,s) {}
  virtual bool solution(const Assignment& x) const {
    return true;
  }
  virtual void post(Space* home, IntVarArray& x) {
  }
};
static Basic _basic;

// STATISTICS: test-int
