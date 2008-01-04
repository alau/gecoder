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

#include "gecode/set.hh"
#include "gecode/set/sequence.hh"

namespace Gecode { namespace Set { namespace Sequence {

  /*
   * "Sequence" propagator
   *
   */

  Actor*
  Seq::copy(Space* home, bool share) {
    return new (home) Seq(home,share,*this);
  }

  ExecStatus
  Seq::propagate(Space* home) {
    bool modified = false;
    bool assigned;
    do {
      assigned = false;
      GECODE_ES_CHECK(propagateSeq(home, modified, assigned, x));
    } while (assigned);

    for (int i=x.size(); i--;) {
      if (!x[i].assigned())
	return ES_FIX;
    }
    return ES_SUBSUMED;
  }

}}}

// STATISTICS: set-prop
