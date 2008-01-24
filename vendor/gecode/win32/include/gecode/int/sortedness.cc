/*
 *  Main authors:
 *     Patrick Pekczynski <pekczynski@ps.uni-sb.de>
 *
 *  Copyright:
 *     Patrick Pekczynski, 2004
 *
 *  Last modified:
 *     $Date: 2006-08-04 16:03:26 +0200 (Fri, 04 Aug 2006) $ by $Author: schulte $
 *     $Revision: 3512 $
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

#include "gecode/int/sortedness.hh"
namespace Gecode {

  using namespace Int;
  void sortedness(Space* home,
		  const IntVarArgs& x,
		  const IntVarArgs& y,
		  IntConLevel) {

    if (home->failed()) {
      return;
    }

    int n  = x.size();
    int n2 = 2*n;

    // construct single tuple for propagation without permutation variables
    ViewArray<ViewTuple<IntView,1> > x0(home, n);
    for (int i = n; i--; ) {
      x0[i][0] = x[i];
    }
    ViewArray<IntView> y0(home, y);

    ViewArray<IntView> xy(home, n2);
    for (int i = 0; i < n; i++) {
      xy[i] = x0[i][0];
    }
    for (int i = n; i < n2; i++) {
      xy[i] = y0[i - n];
    }
    if (xy.shared()) {
      throw ArgumentSame("Int::Sortedness");
    }
    if (n != y.size()) {
      throw ArgumentSizeMismatch("Int::Sortedness");
    }


    GECODE_ES_FAIL(home,
		   (Sortedness::
		    Sortedness<IntView, ViewTuple<IntView,1>, false>::
		    post(home, x0, y0)));
  }

  void sortedness(Space* home,
		  const IntVarArgs& x,
		  const IntVarArgs& y,
		  const IntVarArgs& z,
		  IntConLevel) {
    int n = x.size();
    int n2 = 2*n;
    int n3 = 3*n;

    if ((n != y.size()) || (n != z.size())) {
      throw ArgumentSizeMismatch("Int::sortedness");
    }
    if (home->failed()) {
      return;
    }

    ViewArray<ViewTuple<IntView, 2> > xz0(home, n);

    // assert that permutation variables encode a permutation
    ViewArray<IntView> pz0(home, n);
    ViewArray<IntView> y0(home, y);
    ViewArray<IntView> xyz(home, n3);



    for (int i = n; i--; ) {
      xz0[i][0] = x[i];
      xz0[i][1] = z[i];
      pz0[i]    = z[i];
      // Constrain z_i to a valid index
      GECODE_ME_FAIL(home,xz0[i][1].gq(home,0));
      GECODE_ME_FAIL(home,xz0[i][1].lq(home,n - 1));
    }

    // assert permutation
    distinct(home, z, ICL_BND);

    for (int i = 0; i < n; i++) {
      xyz[i] = xz0[i][0];
    }
    for (int i = n; i < n2; i++) {
      xyz[i] = y0[i - n];
    }
    for (int i = n2; i < n3; i++) {
      xyz[i] = xz0[i - n2][1];
    }

    if (xyz.shared()) {
      throw ArgumentSame("Int::sortedness");
    }

    GECODE_ES_FAIL(home,
		   (Sortedness::
		    Sortedness<IntView, ViewTuple<IntView,2>, true>::
		    post(home, xz0, y0)));
  }
}

// STATISTICS: int-post
