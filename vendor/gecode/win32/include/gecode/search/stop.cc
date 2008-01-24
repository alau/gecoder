/*
 *  Main authors:
 *     Christian Schulte <schulte@gecode.org>
 *
 *  Copyright:
 *     Christian Schulte, 2006
 *
 *  Last modified:
 *     $Date: 2006-08-04 16:03:17 +0200 (Fri, 04 Aug 2006) $ by $Author: schulte $
 *     $Revision: 3511 $
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

#include "gecode/search.hh"

namespace Gecode { namespace Search {

  /*
   * Stopping for memory limit
   *
   */
  bool
  MemoryStop::stop(const Statistics& s) {
    return s.memory > l;
  }


  /*
   * Stopping for memory limit
   *
   */
  bool
  FailStop::stop(const Statistics& s) {
    return s.fail > l;
  }


  /*
   * Stopping for memory limit
   *
   */
  bool
  TimeStop::stop(const Statistics&) {
    return static_cast<unsigned long int>
      ((static_cast<double>(clock()-s)/CLOCKS_PER_SEC) * 1000.0) > l;
  }

}}

// STATISTICS: search-any
