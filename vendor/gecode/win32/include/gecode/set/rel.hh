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
 *     $Date: 2006-05-29 09:42:21 +0200 (Mon, 29 May 2006) $ by $Author: schulte $
 *     $Revision: 3246 $
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

#ifndef __GECODE_SET_REL_HH__
#define __GECODE_SET_REL_HH__

#include "gecode/set.hh"
#include "gecode/iter.hh"

namespace Gecode { namespace Set { namespace Rel {

  /**
   * \namespace Gecode::Set::Rel
   * \brief Standard set relation propagators
   */

  /**
   * \brief %Propagator for the subset constraint
   *
   * Requires \code #include "gecode/set/rel.hh" \endcode
   * \ingroup FuncSetProp
   */

  template <class View0, class View1>
  class SubSet :
    public InhomBinaryPropagator<View0,PC_SET_CGLB,View1,PC_SET_CLUB> {
  protected:
    using InhomBinaryPropagator<View0,PC_SET_CGLB,View1,PC_SET_CLUB>::x0;
    using InhomBinaryPropagator<View0,PC_SET_CGLB,View1,PC_SET_CLUB>::x1;
    /// Constructor for cloning \a p
    SubSet(Space* home, bool share,SubSet& p);
    /// Constructor for posting
    SubSet(Space* home,View0, View1);
  public:
    /// Copy propagator during cloning
    virtual Actor*      copy(Space* home,bool);
    /// Perform propagation
    virtual ExecStatus propagate(Space* home);
    /// Post propagator \f$ x\subseteq y\f$
    static  ExecStatus post(Space* home,View0 x,View1 y);
  };

  /**
   * \brief %Propagator for the negated subset constraint
   *
   * Requires \code #include "gecode/set/rel.hh" \endcode
   * \ingroup FuncSetProp
   */

  template <class View0, class View1>
  class NoSubSet :
    public InhomBinaryPropagator<View0,PC_SET_CLUB,View1,PC_SET_CGLB> {
  protected:
    using InhomBinaryPropagator<View0,PC_SET_CLUB,View1,PC_SET_CGLB>::x0;
    using InhomBinaryPropagator<View0,PC_SET_CLUB,View1,PC_SET_CGLB>::x1;
    /// Constructor for cloning \a p
    NoSubSet(Space* home, bool share,NoSubSet& p);
    /// Constructor for posting
    NoSubSet(Space* home,View0,View1);
  public:
    /// Copy propagator during cloning
    virtual Actor*      copy(Space* home,bool);
    /// Perform propagation
    virtual ExecStatus propagate(Space* home);
    /// Post propagator \f$ x\subseteq y\f$
    static  ExecStatus post(Space* home,View0 x,View1 y);
  };

  /**
   * \brief %Reified subset propagator
   *
   * Requires \code #include "gecode/set/rel.hh" \endcode
   * \ingroup FuncSetProp
   */
  template <class View0, class View1>
  class ReSubset :
    public Propagator {
  protected:
    View0 x0;
    View1 x1;
    Gecode::Int::BoolView b;

    /// Constructor for cloning \a p
    ReSubset(Space* home, bool share,ReSubset&);
    /// Constructor for posting
    ReSubset(Space* home,View0, View1, Gecode::Int::BoolView);
  public:
    /// Copy propagator during cloning
    virtual Actor*      copy(Space* home,bool);
    /// Cost function (defined as PC_TERNARY_LO)
    virtual PropCost cost(void) const;
    /// Delete propagator and return its size
    virtual size_t dispose(Space* home);
    /// Perform propagation
    virtual ExecStatus propagate(Space* home);
    /// Post propagator for \f$ (x\subseteq y) \Leftrightarrow b \f$ 
    static ExecStatus post(Space* home,View0 x, View1 y,
			   Gecode::Int::BoolView b);
  };

  /**
   * \brief %Propagator for set equality
   *
   * Requires \code #include "gecode/set/rel.hh" \endcode
   * \ingroup FuncSetProp
   */

  template <class View0, class View1>
  class Eq : 
    public InhomBinaryPropagator<View0,PC_SET_ANY,View1,PC_SET_ANY> {
  protected:
    using InhomBinaryPropagator<View0,PC_SET_ANY,View1,PC_SET_ANY>::x0;
    using InhomBinaryPropagator<View0,PC_SET_ANY,View1,PC_SET_ANY>::x1;
    /// Constructor for cloning \a p
    Eq(Space* home, bool share,Eq& p);
    /// Constructor for posting
    Eq(Space* home,View0, View1);
  public:
    /// Copy propagator during cloning
    virtual Actor*      copy(Space* home,bool);
    /// Perform propagation
    virtual ExecStatus  propagate(Space* home);
    /// Post propagator \f$ x=y \f$ 
    static  ExecStatus  post(Space* home,View0,View1);
  };

  /**
   * \brief %Reified equality propagator
   *
   * Requires \code #include "gecode/set/rel.hh" \endcode
   * \ingroup FuncSetProp
   */
  template <class View0, class View1>
  class ReEq :
    public Propagator {
  protected:
    View0 x0;
    View1 x1;
    Gecode::Int::BoolView b;

    /// Constructor for cloning \a p
    ReEq(Space* home, bool share,ReEq&);
    /// Constructor for posting
    ReEq(Space* home,View0, View1, Gecode::Int::BoolView);
  public:
    /// Copy propagator during cloning
    virtual Actor*      copy(Space* home,bool);
    /// Cost function (defined as PC_TERNARY_LO)
    virtual PropCost cost(void) const;
    /// Delete propagator and return its size
    virtual size_t dispose(Space* home);
    /// Perform propagation
    virtual ExecStatus propagate(Space* home);
  /// Post propagator for \f$ (x=y) \Leftrightarrow b\f$ 
    static ExecStatus post(Space* home,View0 x, View1 y,
			   Gecode::Int::BoolView b);
  };

  /**
   * \brief %Propagator for negated equality
   *
   * Requires \code #include "gecode/set/rel.hh" \endcode
   * \ingroup FuncSetProp   
   */

  template <class View0, class View1>
  class Distinct :
    public InhomBinaryPropagator<View0,PC_SET_VAL,View1,PC_SET_VAL> {
  protected:
    using InhomBinaryPropagator<View0,PC_SET_VAL,View1,PC_SET_VAL>::x0;
    using InhomBinaryPropagator<View0,PC_SET_VAL,View1,PC_SET_VAL>::x1;
    /// Constructor for cloning \a p
    Distinct(Space* home, bool share,Distinct& p);
    /// Constructor for posting
    Distinct(Space* home,View0,View1);
  public:
    /// Copy propagator during cloning
    virtual Actor*      copy(Space* home,bool);
    /// Perform propagation
    virtual ExecStatus  propagate(Space* home);
    /// Post propagator \f$ x\neq y \f$ 
    static  ExecStatus  post(Space* home,View0,View1);
  };

  /**
   * \brief %Propagator for negated equality
   *
   * This propagator actually propagates the distinctness, after the
   * Distinct propagator waited for one variable to become
   * assigned.
   *
   * Requires \code #include "gecode/set/rel.hh" \endcode
   * \ingroup FuncSetProp   
   */
  template <class View0, class View1>
  class DistinctDoit : public UnaryPropagator<View0,PC_SET_ANY> {
  protected:
    using UnaryPropagator<View0,PC_SET_ANY>::x0;
    /// The view that is already assigned
    View1 y;
    /// Constructor for cloning \a p
    DistinctDoit(Space* home, bool share,DistinctDoit&);
    /// Constructor for posting
    DistinctDoit(Space* home, View0, View1);
  public:
    /// Copy propagator during cloning
    virtual Actor*      copy(Space* home, bool);
    /// Perform propagation
    virtual ExecStatus propagate(Space* home);
    /// Post propagator \f$ x\neq y \f$ 
    static ExecStatus post(Space* home, View0, View1);
  };

}}}

#include "gecode/set/rel/common.icc"
#include "gecode/set/rel/subset.icc"
#include "gecode/set/rel/nosubset.icc"
#include "gecode/set/rel/re-subset.icc"
#include "gecode/set/rel/eq.icc"
#include "gecode/set/rel/re-eq.icc"
#include "gecode/set/rel/nq.icc"

#endif

// STATISTICS: set-prop
