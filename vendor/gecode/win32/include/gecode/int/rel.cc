/*
 *  Main authors:
 *     Christian Schulte <schulte@gecode.org>
 *     Gabor Szokoli <szokoli@gecode.org>
 *
 *  Copyright:
 *     Christian Schulte, 2002
 *     Gabor Szokoli, 2003
 *
 *  Last modified:
 *     $Date: 2006-08-31 17:36:38 +0200 (Thu, 31 Aug 2006) $ by $Author: schulte $
 *     $Revision: 3579 $
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

#include "gecode/int/rel.hh"

#include <algorithm>

namespace Gecode {

  using namespace Int;

  void
  rel(Space* home, IntVar x0, IntRelType r, int n, IntConLevel) {
    if (home->failed()) return;
    IntView x(x0);
    switch (r) {
    case IRT_EQ:
      GECODE_ME_FAIL(home,x.eq(home,n)); break;
    case IRT_NQ:
      GECODE_ME_FAIL(home,x.nq(home,n)); break;
    case IRT_LQ:
      GECODE_ME_FAIL(home,x.lq(home,n)); break;
    case IRT_LE:
      GECODE_ME_FAIL(home,x.le(home,n)); break;
    case IRT_GQ:
      GECODE_ME_FAIL(home,x.gq(home,n)); break;
    case IRT_GR:
      GECODE_ME_FAIL(home,x.gr(home,n)); break;
    default:
      throw UnknownRelation("Int::rel");
    }
  }

  void
  rel(Space* home, IntVar x0, IntRelType r, IntVar x1, IntConLevel icl) {
    if (home->failed()) return;
    switch (r) {
    case IRT_EQ:
      if (icl == ICL_BND) {
	GECODE_ES_FAIL(home,(Rel::EqBnd<IntView,IntView>::post(home,x0,x1)));
      } else {
	GECODE_ES_FAIL(home,(Rel::EqDom<IntView,IntView>::post(home,x0,x1)));
      }
      break;
    case IRT_NQ:
      GECODE_ES_FAIL(home,Rel::Nq<IntView>::post(home,x0,x1)); break;
    case IRT_GQ:
      std::swap(x0,x1); // Fall through
    case IRT_LQ:
      GECODE_ES_FAIL(home,Rel::Lq<IntView>::post(home,x0,x1)); break;
    case IRT_GR:
      std::swap(x0,x1); // Fall through
    case IRT_LE:
      GECODE_ES_FAIL(home,Rel::Le<IntView>::post(home,x0,x1)); break;
    default:
      throw UnknownRelation("Int::rel");
    }
  }


  void
  rel(Space* home, IntVar x0, IntRelType r, IntVar x1, BoolVar b,
      IntConLevel icl) {
    if (home->failed()) return;
    switch (r) {
    case IRT_EQ:
      if (icl == ICL_BND) {
	GECODE_ES_FAIL(home,(Rel::ReEqBnd<IntView,BoolView>
			     ::post(home,x0,x1,b)));
      } else {
	GECODE_ES_FAIL(home,(Rel::ReEqDom<IntView,BoolView>
			     ::post(home,x0,x1,b)));
      }
      break;
    case IRT_NQ:
      {
	NegBoolView n(b);
	if (icl == ICL_BND) {
	  GECODE_ES_FAIL(home,(Rel::ReEqBnd<IntView,NegBoolView>
			       ::post(home,x0,x1,n)));
	} else {
	  GECODE_ES_FAIL(home,(Rel::ReEqDom<IntView,NegBoolView>
			       ::post(home,x0,x1,n)));
	}
      }
      break;
    case IRT_GQ:
      std::swap(x0,x1); // Fall through
    case IRT_LQ:
      GECODE_ES_FAIL(home,(Rel::ReLq<IntView,BoolView>::post(home,x0,x1,b)));
      break;
    case IRT_LE:
      std::swap(x0,x1); // Fall through
    case IRT_GR:
      {
	NegBoolView n(b);
	GECODE_ES_FAIL(home,(Rel::ReLq<IntView,NegBoolView>::post(home,x0,x1,n)));
      }
      break;
    default:
      throw UnknownRelation("Int::rel");
    }
  }

  void
  rel(Space* home, IntVar x, IntRelType r, int n, BoolVar b,
      IntConLevel icl) {
    if (home->failed()) return;
    switch (r) {
    case IRT_EQ:
      if (icl == ICL_BND) {
	GECODE_ES_FAIL(home,(Rel::ReEqBndInt<IntView,BoolView>
			     ::post(home,x,n,b)));
      } else {
	GECODE_ES_FAIL(home,(Rel::ReEqDomInt<IntView,BoolView>
			     ::post(home,x,n,b)));
      }
      break;
    case IRT_NQ:
      {
	NegBoolView nb(b);
	if (icl == ICL_BND) {
	  GECODE_ES_FAIL(home,(Rel::ReEqBndInt<IntView,NegBoolView>
			       ::post(home,x,n,nb)));
	} else {
	  GECODE_ES_FAIL(home,(Rel::ReEqDomInt<IntView,NegBoolView>
			       ::post(home,x,n,nb)));
	}
      }
      break;
    case IRT_LE:
      n--; // Fall through
    case IRT_LQ:
      GECODE_ES_FAIL(home,(Rel::ReLqInt<IntView,BoolView>
			   ::post(home,x,n,b)));
      break;
    case IRT_GQ:
      n--; // Fall through
    case IRT_GR:
      {
	NegBoolView nb(b);
	GECODE_ES_FAIL(home,(Rel::ReLqInt<IntView,NegBoolView>
			     ::post(home,x,n,nb)));
      }
      break;
    default:
      throw UnknownRelation("Int::rel");
    }
  }

  void
  eq(Space* home, IntVar x0, IntVar x1, IntConLevel icl) {
    if (home->failed()) return;
    if (icl == ICL_BND) {
      GECODE_ES_FAIL(home,(Rel::EqBnd<IntView,IntView>::post(home,x0,x1)));
    } else {
      GECODE_ES_FAIL(home,(Rel::EqDom<IntView,IntView>::post(home,x0,x1)));
    }
  }

  void
  eq(Space* home, IntVar x0, int n, IntConLevel) {
    if (home->failed()) return;
    IntView x(x0);
    GECODE_ME_FAIL(home,x.eq(home,n));
  }

  void
  eq(Space* home, IntVar x0, IntVar x1, BoolVar b, IntConLevel icl) {
    if (home->failed()) return;
    if (icl == ICL_BND) {
      GECODE_ES_FAIL(home,(Rel::ReEqBnd<IntView,BoolView>::post(home,x0,x1,b)));
    } else {
      GECODE_ES_FAIL(home,(Rel::ReEqDom<IntView,BoolView>::post(home,x0,x1,b)));
    }
  }

  void
  eq(Space* home, IntVar x, int n, BoolVar b, IntConLevel icl) {
    if (home->failed()) return;
    if (icl == ICL_BND) {
      GECODE_ES_FAIL(home,(Rel::ReEqBndInt<IntView,BoolView>::post(home,x,n,b)));
    } else {
      GECODE_ES_FAIL(home,(Rel::ReEqDomInt<IntView,BoolView>::post(home,x,n,b)));
    }
  }

  void
  eq(Space* home, const IntVarArgs& x, IntConLevel icl) {
    if (home->failed()) return;
    ViewArray<IntView> xv(home,x);
    if (icl == ICL_BND) {
      GECODE_ES_FAIL(home,Rel::NaryEqBnd<IntView>::post(home,xv));
    } else {
      GECODE_ES_FAIL(home,Rel::NaryEqDom<IntView>::post(home,xv));
    }
  }


  void
  rel(Space* home, const IntVarArgs& x, IntRelType r, const IntVarArgs& y,
      IntConLevel icl) {
    if (x.size() != y.size())
      throw ArgumentSizeMismatch("Int::rel");
    if (home->failed()) return;

    switch (r) {
    case IRT_GR: 
      {
	ViewArray<ViewTuple<IntView,2> > xy(home,x.size());
	for (int i = x.size(); i--; ) {
	  xy[i][0]=y[i]; xy[i][1]=x[i];
	}
	GECODE_ES_FAIL(home,Rel::Lex<IntView>::post(home,xy,true));
      }
      break;
    case IRT_LE: 
      {
	ViewArray<ViewTuple<IntView,2> > xy(home,x.size());
	for (int i = x.size(); i--; ) {
	  xy[i][0]=x[i]; xy[i][1]=y[i];
	}
	GECODE_ES_FAIL(home,Rel::Lex<IntView>::post(home,xy,true));
      }
      break;
    case IRT_GQ: 
      {
	ViewArray<ViewTuple<IntView,2> > xy(home,x.size());
	for (int i = x.size(); i--; ) {
	  xy[i][0]=y[i]; xy[i][1]=x[i];
	}
	GECODE_ES_FAIL(home,Rel::Lex<IntView>::post(home,xy,false));
      }
      break;
    case IRT_LQ: 
      {
	ViewArray<ViewTuple<IntView,2> > xy(home,x.size());
	for (int i = x.size(); i--; ) {
	  xy[i][0]=x[i]; xy[i][1]=y[i];
	}
	GECODE_ES_FAIL(home,Rel::Lex<IntView>::post(home,xy,false));
      }
      break;
    case IRT_EQ:
      if (icl == ICL_BND)
	for (int i=x.size(); i--; ) {
	  GECODE_ES_FAIL(home,(Rel::EqBnd<IntView,IntView>
			       ::post(home,x[i],y[i])));
	}
      else
	for (int i=x.size(); i--; ) {
	  GECODE_ES_FAIL(home,(Rel::EqDom<IntView,IntView>
			       ::post(home,x[i],y[i])));
	}
      break;
    case IRT_NQ: 
      {
	ViewArray<ViewTuple<IntView,2> > xy(home,x.size());
	for (int i = x.size(); i--; ) {
	  xy[i][0]=x[i]; xy[i][1]=y[i];
	}
	GECODE_ES_FAIL(home,Rel::NaryNq<IntView>::post(home,xy));
      }
      break;
    default:
      throw UnknownRelation("Int::rel");
    }
  }

}

// STATISTICS: int-post

