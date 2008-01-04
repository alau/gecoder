/*
 *  Main authors:
 *     Guido Tack <tack@gecode.org>
 *
 *  Copyright:
 *     Guido Tack, 2004
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
#include "gecode/set/distinct/binomial.icc"

namespace Gecode { namespace Set { namespace Distinct {

  void
  Binomial::init(unsigned int n) {
    int n2 = (n-2)/2;
    int nn = n2*(n2-1);
    nn += n2;
    if (n % 2 == 1)
      nn += n2;

    //    sar.ensure(n*(n-1)/2);
    sar.ensure(nn);
    unsigned int oldnmax = nmax;
    nmax = n;
    for (unsigned int i=oldnmax+1; i<=n; i++)
      for (unsigned int j=2; j<=(i/2); j++)
	y(i, j, y(i-1, j-1) + y(i-1, j));
  }

}}}

// STATISTICS: set-prop
