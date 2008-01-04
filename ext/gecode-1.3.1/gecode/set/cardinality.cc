/*
 *  Main authors:
 *     Gabor Szokoli <szokoli@gecode.org>
 *     Guido Tack <tack@gecode.org>
 *     Christian Schulte <schulte@gecode.org>
 *
 *  Copyright:
 *     Gabor Szokoli, 2004
 *     Guido Tack, 2004
 *     Christian Schulte, 2004
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
#include "gecode/set/int.hh"

namespace Gecode {

  void
  cardinality(Space* home, SetVar x, unsigned int i, unsigned int j) {
    if (home->failed()) return;
    Set::SetView _x(x);
    GECODE_ME_FAIL(home,_x.cardMin(home, i));
    GECODE_ME_FAIL(home,_x.cardMax(home, j));
  }

  void
  cardinality(Space* home, SetVar s, IntVar x) {
    if (home->failed()) return;
    GECODE_ES_FAIL(home,Set::Int::Card::post(home,s, x));
  }

}

// STATISTICS: set-post
