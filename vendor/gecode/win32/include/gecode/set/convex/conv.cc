/*
 *  Main authors:
 *     Guido Tack <tack@gecode.org>
 *     Christian Schulte <schulte@gecode.org>
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
#include "gecode/set/convex.hh"

#include "gecode/iter.hh"

namespace Gecode { namespace Set { namespace Convex {

  Actor*
  Convex::copy(Space* home, bool share) {
    return new (home) Convex(home,share,*this);
  }

  ExecStatus
  Convex::propagate(Space* home) {
    //I, drop ranges from UB that are shorter than cardMin
    //II, add range LB.smallest to LB.largest to LB
    //III, Drop ranges from UB that do not contain all elements of LB
    //that is: range.min()>LB.smallest or range.max()<LB.largest
    //This leaves only one range.

    //II
    if (x0.glbSize()>0) {
      GECODE_ME_CHECK( x0.include(home,x0.glbMin(),x0.glbMax()) );
    } else {
      //If lower bound is empty, we can still constrain the cardinality
      //maximum with the width of the longest range in UB.
      //No need to do this if there is anything in LB because UB
      //becomes a single range then.
       LubRanges<SetView> ubRangeIt(x0);
       unsigned int maxWidth = 0;
       for (;ubRangeIt();++ubRangeIt){
         maxWidth = std::max(maxWidth, ubRangeIt.width());
       }
        GECODE_ME_CHECK( x0.cardMax(home,maxWidth) );
    }


    //I + III

    LubRanges<SetView> ubRangeIt(x0);
    Iter::Ranges::Cache< LubRanges<SetView> > ubRangeItC(ubRangeIt);
    for (;ubRangeItC();++ubRangeItC){
      if (ubRangeItC.width() < (unsigned int) x0.cardMin()
          || ubRangeItC.min() > x0.glbMin() //No need to test for empty lb.
          || ubRangeItC.max() < x0.glbMax()
          ) {
        GECODE_ME_CHECK( x0.exclude(home,ubRangeItC.min(), ubRangeItC.max()) );
      }
    }
    if (x0.assigned()) {return ES_SUBSUMED;}
    return ES_FIX;
  }

}}}

// STATISTICS: set-prop
