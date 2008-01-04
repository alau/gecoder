/*
 *  Main authors:
 *     Christian Schulte <schulte@gecode.org>
 *
 *  Copyright:
 *     Christian Schulte, 2004
 *
 *  Last modified:
 *     $Date: 2005-11-02 13:53:36 +0100 (Wed, 02 Nov 2005) $ by $Author: schulte $
 *     $Revision: 2470 $
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

#include "examples/timer.hh"

double
am(double t[], int n) {
  if (n < 1)
    return 0.0;
  double s = 0;
  for (int i=n; i--; )
    s += t[i];
  return s / n;
}

double
dev(double t[], int n) {
  if (n < 2)
    return 0.0;
  double m = am(t,n);
  double s = 0.0;
  for (int i=n; i--; ) {
    double d = t[i]-m;
    s += d*d;
  }
  return sqrt(s / (n-1)) / m;
}

// STATISTICS: example-any
