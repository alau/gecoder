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
 *     $Date: 2006-05-29 09:42:21 +0200 (Mon, 29 May 2006) $ by $Author: schulte $
 *     $Revision: 3246 $
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

  PropCost
  Channel::cost(void) const {
    return PC_QUADRATIC_LO;
  }

  size_t
  Channel::dispose(Space* home) {
    assert(!home->failed());
    xs.cancel(home,this, Gecode::Int::PC_INT_DOM);
    ys.cancel(home,this, PC_SET_ANY);
    (void) Propagator::dispose(home);
    return sizeof(*this);
  }

  Actor*
  Channel::copy(Space* home, bool share) {
    return new (home) Channel(home,share,*this);
  }

  ExecStatus
  Channel::propagate(Space* home) {
    int assigned = 0;
    for (int v=xs.size(); v--;) {
      if (xs[v].assigned()) {
	assigned += 1;
        for (int i=ys.size(); i--;) {
          if (i==xs[v].val()) {
            GECODE_ME_CHECK(ys[i].include(home, v));
          }
          else {
            GECODE_ME_CHECK(ys[i].exclude(home, v));
          }
        }
      } else {

        for (int i=ys.size(); i--;) {
          if (ys[i].notContains(v)) {
            GECODE_ME_CHECK(xs[v].nq(home, i));
          }
          if (ys[i].contains(v)) {
            GECODE_ME_CHECK(xs[v].eq(home, i));
          }
        }

        Gecode::Int::ViewRanges<Gecode::Int::IntView> xsv(xs[v]);
        int min = 0;
        for (; xsv(); ++xsv) {
          for (int i=min; i<xsv.min(); i++) {
            GECODE_ME_CHECK(ys[i].exclude(home, v));
          }
          min = xsv.max() + 1;
        }

      }
    }

    return (assigned==xs.size()) ? ES_SUBSUMED : ES_NOFIX;
  }


}}}

// STATISTICS: set-prop
