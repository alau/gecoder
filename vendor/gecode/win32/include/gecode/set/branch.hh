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
 *     $Date: 2006-07-18 15:39:20 +0200 (Tue, 18 Jul 2006) $ by $Author: schulte $
 *     $Revision: 3390 $
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

#ifndef __GECODE_SET_BRANCH_HH__
#define __GECODE_SET_BRANCH_HH__

#include "gecode/set.hh"
#include "gecode/iter.hh"

/**
 * \namespace Gecode::Set::Branch
 * \brief %Set branchings
 */

namespace Gecode { namespace Set { namespace Branch {

  /*
   * Value selection classes
   *
   */


  /**
   * \brief Class for selecting minimum value
   *
   * All value selection classes require 
   * \code #include "gecode/set/branch.hh" \endcode
   * \ingroup FuncSetSelVal
   */
  class ValMin {
  public:
    /// Return minimum value of view \a x
    int val(const Space* home, SetView x) const;
    /// Tell \f$v\in x\f$ (\a a = 0) or \f$v\notin x\f$ (\a a = 1)
    ModEvent tell(Space* home, unsigned int a, SetView x, int v);
  };

  /**
   * \brief Class for selecting maximum value
   *
   * All value selection classes require 
   * \code #include "gecode/set/branch.hh" \endcode
   * \ingroup FuncSetSelVal
   */
  class ValMax {
  public:
    /// Return maximum value of view \a x
    int val(const Space* home, SetView x) const;
    /// Tell \f$v\in x\f$ (\a a = 0) or \f$v\notin x\f$ (\a a = 1)
    ModEvent tell(Space* home, unsigned int a, SetView x, int v);
  };

  /// Create branchings for a given view selection strategy \a ViewSel
  template <class SelView>
  static void
  create(Space* home, ViewArray<SetView>&, SetBvalSel);

  /*
   * View selection classes
   *
   */

  /**
   * \brief View selection class for first view
   *
   * Requires \code #include "gecode/set/branch.hh" \endcode
   * \ingroup FuncSetSelView
   */
  class ByNone {
  public:
    /// Intialize with view \a x
    ViewSelStatus init(const Space* home, SetView x);
    /// Possibly select better view \a x
    ViewSelStatus select(const Space* home, SetView x);
  };

  /**
   * \brief View selection class for view with smallest cardinality of lub-glb
   *
   * Requires \code #include "gecode/set/branch.hh" \endcode
   * \ingroup FuncSetSelView
   */
  class ByMinCard {
  private:
    /// So-far smallest cardinality
    unsigned int minCard;
  public:
    /// Intialize with view \a x
    ViewSelStatus init(const Space* home, SetView x);
    /// Possibly select better view \a x
    ViewSelStatus select(const Space* home, SetView x);
  };

  /**
   * \brief View selection class for view with greatest cardinality of lub-glb
   *
   * Requires \code #include "gecode/set/branch.hh" \endcode
   * \ingroup FuncSetSelView
   */
  class ByMaxCard {
  private:
    /// So-far greatest cardinality
    unsigned int maxCard;
  public:
    /// Intialize with view \a x
    ViewSelStatus init(const Space* home, SetView x);
    /// Possibly select better view \a x
    ViewSelStatus select(const Space* home, SetView x);
  };

  /**
   * \brief View selection class for view with smallest element in lub-glb
   *
   * Requires \code #include "gecode/set/branch.hh" \endcode
   * \ingroup FuncSetSelView
   */
  class ByMinUnknown {
  private:
    /// So-far smallest element
    int minUnknown;
  public:
    /// Intialize with view \a x
    ViewSelStatus init(const Space* home, SetView x);
    /// Possibly select better view \a x
    ViewSelStatus select(const Space* home, SetView x);
  };

  /**
   * \brief View selection class for view with greatest element in lub-glb
   *
   * Requires \code #include "gecode/set/branch.hh" \endcode
   * \ingroup FuncSetSelView
   */
  class ByMaxUnknown {
  private:
    /// So-far greatest element
    int maxUnknown;
  public:
    /// Intialize with view \a x
    ViewSelStatus init(const Space* home, SetView x);
    /// Possibly select better view \a x
    ViewSelStatus select(const Space* home, SetView x);
  };

}}}

#include "gecode/set/branch/select-val.icc"
#include "gecode/set/branch/select-view.icc"

#endif
// STATISTICS: set-branch

