/*
 *  Main authors:
 *     Christian Schulte <schulte@gecode.org>
 *
 *  Copyright:
 *     Christian Schulte, 2004
 *
 *  Bugfixes provided by:
 *     Javier Andr�s Mena Zapata <javimena@gmail.com>
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

#ifndef __GECODE_EXAMPLES_TIMER_HH__
#define __GECODE_EXAMPLES_TIMER_HH__

#include <ctime>
#include <cmath>

#include "gecode/config.icc"

/*
 * Support for measuring time
 *
 */

/// Timer interface used for examples
class Timer {
private:
  clock_t t0;
public:
  void start(void);
  double stop(void);
};

forceinline void
Timer::start(void) {
  t0 = clock();
}
forceinline double
Timer::stop(void) {
  return (static_cast<double>(clock()-t0) / CLOCKS_PER_SEC) * 1000.0;
}


/**
 * \brief Compute arithmetic mean of \a n elements in \a t
 * \relates Timer
 */
double
am(double t[], int n);
/**
 * \brief Compute deviation of \a n elements in \a t
 * \relates Timer
 */
double
dev(double t[], int n);

#endif

// STATISTICS: example-any
