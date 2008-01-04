/*
 *  Main authors:
 *     Christian Schulte <schulte@gecode.org>
 *
 *  Copyright:
 *     Christian Schulte, 2004
 *
 *  Last modified:
 *     $Date: 2006-08-04 15:23:45 +0200 (Fri, 04 Aug 2006) $ by $Author: schulte $
 *     $Revision: 3509 $
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

#include "gecode/int/element.hh"

namespace Gecode {

  using namespace Int;

  void
  element(Space* home, const IntArgs& c, IntVar x0, IntVar x1,
	  IntConLevel) {
    if (home->failed()) return;
    Element::IntSharedArray cs(c.size());
    for (int i = c.size(); i--; )
      if ((c[i] < Limits::Int::int_min) || (c[i] > Limits::Int::int_max))
	throw NumericalOverflow("Int::element");
      else
	cs[i] = c[i];
    GECODE_ES_FAIL(home,(Element::Int<IntView,IntView>::post(home,cs,x0,x1)));
  }

  void
  element(Space* home, const IntVarArgs& c, IntVar x0, IntVar x1,
	  IntConLevel icl) {
    if (home->failed()) return;
    Element::IdxView<IntView>* iv = Element::IdxView<IntView>::init(home,c);
    if (icl == ICL_BND) {
      GECODE_ES_FAIL(home,(Element::ViewBnd<IntView,IntView>
			   ::post(home,iv,c.size(),x0,x1)));
    } else {
      GECODE_ES_FAIL(home,(Element::ViewDom<IntView,IntView>
			   ::post(home,iv,c.size(),x0,x1)));
    }
  }

}

// STATISTICS: int-post

