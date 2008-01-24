/*
 *  Main authors:
 *     Guido Tack <tack@gecode.org>
 *     Christian Schulte <schulte@gecode.org>
 *
 *  Contributing authors:
 *     Gabor Szokoli <szokoli@gecode.org>
 *
 *  Copyright:
 *     Guido Tack, 2004
 *     Christian Schulte, 2004
 *     Gabor Szokoli, 2004
 *
 *  Last modified:
 *     $Date: 2006-04-11 15:58:37 +0200 (Tue, 11 Apr 2006) $ by $Author: tack $
 *     $Revision: 3188 $
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



#include "gecode/set/int.hh"

#include "gecode/iter.hh"

#include "gecode/set/rel.hh"

namespace Gecode { namespace Set { namespace Int {

  Actor*
  Card::copy(Space* home, bool share) {
    return new (home) Card(home,share,*this);
  }

  ExecStatus
  Card::propagate(Space* home) {
    int x1min, x1max;
    do {
      x1min = x1.min();
      x1max = x1.max();
      GECODE_ME_CHECK(x0.cardMin(home,x1min));
      GECODE_ME_CHECK(x0.cardMax(home,x1max));
      GECODE_ME_CHECK(x1.gq(home,(int)x0.cardMin()));
      GECODE_ME_CHECK(x1.lq(home,(int)x0.cardMax()));
    } while (x1.min() > x1min || x1.max() < x1max);
    if (x1.assigned())
      return ES_SUBSUMED;
    return ES_FIX;
  }

}}}

// STATISTICS: set-prop
