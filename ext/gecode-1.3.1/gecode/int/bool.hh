/*
 *  Main authors:
 *     Christian Schulte <schulte@gecode.org>
 *     Guido Tack <tack@gecode.org>
 *
 *  Copyright:
 *     Christian Schulte, 2002
 *     Guido Tack, 2004
 *
 *  Last modified:
 *     $Date: 2006-09-05 21:48:13 +0200 (Tue, 05 Sep 2006) $ by $Author: schulte $
 *     $Revision: 3600 $
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

#ifndef __GECODE_INT_BOOL_HH__
#define __GECODE_INT_BOOL_HH__

#include "gecode/int.hh"

/**
 * \namespace Gecode::Int::Bool
 * \brief Boolean propagators
 */

namespace Gecode { namespace Int { namespace Bool {

  /*
   * Base Classes
   *
   */

  /// Base-class for binary Boolean propagators
  template<class BVA, class BVB>
  class BoolBinary : public Propagator {
  protected:
    BVA x0; ///< Boolean view
    BVB x1; ///< Boolean view
    /// Constructor for posting
    BoolBinary(Space* home, BVA b0, BVB b1);
    /// Constructor for cloning
    BoolBinary(Space* home, bool share, BoolBinary& p);
    /// Constructor for rewriting \a p during cloning
    BoolBinary(Space* home, bool share, Propagator& p,
	       BVA b0, BVB b1);
  public:
    /// Cost function (defined as PC_UNARY_LO)
    virtual PropCost cost(void) const;
    /// Delete propagator and return its size
    virtual size_t dispose(Space* home);
  };

  /// Base-class for ternary Boolean propagators
  template<class BVA, class BVB, class BVC>
  class BoolTernary : public Propagator {
  protected:
    BVA x0; ///< Boolean view
    BVB x1; ///< Boolean view
    BVC x2; ///< Boolean view
    /// Constructor for posting
    BoolTernary(Space* home, BVA b0, BVB b1, BVC b2);
    /// Constructor for cloning
    BoolTernary(Space* home, bool share, BoolTernary& p);
  public:
    /// Constructor for rewriting \a p during cloning
    BoolTernary(Space* home, bool share, Propagator& p,
		BVA b0, BVB b1, BVC b2);
    /// Cost function (defined as PC_BINARY_LO)
    virtual PropCost cost(void) const;
    /// Delete propagator and return its size
    virtual size_t dispose(Space* home);
  };

  /**
   * \brief Boolean equality propagator
   *
   * Requires \code #include "gecode/int/bool.hh" \endcode
   * \ingroup FuncIntProp
   */
  template<class BVA, class BVB>
  class Eq : public BoolBinary<BVA,BVB> {
  protected:
    using BoolBinary<BVA,BVB>::x0;
    using BoolBinary<BVA,BVB>::x1;
    /// Constructor for posting
    Eq(Space* home, BVA b0, BVB b1);
    /// Constructor for cloning \a p
    Eq(Space* home, bool share, Eq& p);
  public:
    /// Constructor for rewriting \a p during cloning
    Eq(Space* home, bool share, Propagator& p,
       BVA b0, BVB b1);
    /// Copy propagator during cloning
    virtual Actor* copy(Space* home, bool share);
    /// Perform propagation
    virtual ExecStatus propagate(Space* home);
    /// Post propagator \f$ b_0 = b_1\f$
    static  ExecStatus post(Space* home, BVA b0, BVB b1);
  };


  /**
   * \brief Boolean disjunction propagator (true)
   *
   * Requires \code #include "gecode/int/bool.hh" \endcode
   * \ingroup FuncIntProp
   */
  template<class BVA, class BVB>
  class OrTrue : public BoolBinary<BVA,BVB> {
  protected:
    using BoolBinary<BVA,BVB>::x0;
    using BoolBinary<BVA,BVB>::x1;
    /// Constructor for posting
    OrTrue(Space* home, BVA b0, BVB b1);
    /// Constructor for cloning \a p
    OrTrue(Space* home, bool share, OrTrue& p);
  public:
    /// Constructor for rewriting \a p during cloning
    OrTrue(Space* home, bool share, Propagator& p,
	     BVA b0, BVB b1);
    /// Copy propagator during cloning
    virtual Actor* copy(Space* home, bool share);
    /// Perform propagation
    virtual ExecStatus propagate(Space* home);
    /// Post propagator \f$ b_0 \lor b_1 = 0 \f$
    static  ExecStatus post(Space* home, BVA b0, BVB b1);
  };

  /**
   * \brief Boolean disjunction propagator
   *
   * Requires \code #include "gecode/int/bool.hh" \endcode
   * \ingroup FuncIntProp
   */
  template<class BVA, class BVB, class BVC>
  class Or : public BoolTernary<BVA,BVB,BVC> {
  protected:
    using BoolTernary<BVA,BVB,BVC>::x0;
    using BoolTernary<BVA,BVB,BVC>::x1;
    using BoolTernary<BVA,BVB,BVC>::x2;
    /// Constructor for posting
    Or(Space* home, BVA b0, BVB b1, BVC b2);
    /// Constructor for cloning \a p
    Or(Space* home, bool share, Or& p);
  public:
    /// Constructor for rewriting \a p during cloning
    Or(Space* home, bool share, Propagator& p, BVA b0, BVB b1, BVC b2);
    /// Copy propagator during cloning
    virtual Actor* copy(Space* home, bool share);
    /// Perform propagation
    virtual ExecStatus propagate(Space* home);
    /// Post propagator \f$ b_0 \lor b_1 = b_2 \f$
    static  ExecStatus post(Space* home, BVA b0, BVB b1, BVC b2);
  };

  /**
   * \brief Boolean n-ary disjunction propagator
   *
   * Requires \code #include "gecode/int/bool.hh" \endcode
   * \ingroup FuncIntProp
   */
  template<class View>
  class NaryOr : public NaryOnePropagator<View,PC_INT_VAL> {
  protected:
    using NaryOnePropagator<View,PC_INT_VAL>::x;
    using NaryOnePropagator<View,PC_INT_VAL>::y;
    /// Constructor for posting
    NaryOr(Space* home,  ViewArray<View>& b, View c);
    /// Constructor for cloning \a p
    NaryOr(Space* home, bool share, NaryOr<View>& p);
  public:
    /// Copy propagator during cloning
    virtual Actor* copy(Space* home, bool share);
    /// Perform propagation
    virtual ExecStatus propagate(Space* home);
    /// Post propagator \f$ \bigvee_{i=0}^{|b|-1} b_i = c\f$
    static  ExecStatus post(Space* home, ViewArray<View>& b, View c);
  };


  /**
   * \brief Boolean n-ary disjunction propagator (true)
   *
   * Requires \code #include "gecode/int/bool.hh" \endcode
   * \ingroup FuncIntProp
   */
  template<class View>
  class NaryOrTrue : public BinaryPropagator<View,PC_INT_VAL> {
  protected:
    using BinaryPropagator<View,PC_INT_VAL>::x0;
    using BinaryPropagator<View,PC_INT_VAL>::x1;
    /// Views not yet subscribed to
    ViewArray<View> x;
    /// Update subscription
    ExecStatus resubscribe(Space* home, View& x0, View x1);
    /// Constructor for posting
    NaryOrTrue(Space* home,  ViewArray<View>& b);
    /// Constructor for cloning \a p
    NaryOrTrue(Space* home, bool share, NaryOrTrue<View>& p);
  public:
    /// Copy propagator during cloning
    virtual Actor* copy(Space* home, bool share);
    /// Cost function (defined as PC_LINEAR_LO)
    virtual PropCost cost(void) const;
    /// Perform propagation
    virtual ExecStatus propagate(Space* home);
    /// Post propagator \f$ \bigvee_{i=0}^{|b|-1} b_i = 0\f$
    static  ExecStatus post(Space* home, ViewArray<View>& b);
  };


  /**
   * \brief Boolean equivalence propagator
   *
   * Requires \code #include "gecode/int/bool.hh" \endcode
   * \ingroup FuncIntProp
   */
  template<class BVA, class BVB, class BVC>
  class Eqv : public BoolTernary<BVA,BVB,BVC> {
  protected:
    using BoolTernary<BVA,BVB,BVC>::x0;
    using BoolTernary<BVA,BVB,BVC>::x1;
    using BoolTernary<BVA,BVB,BVC>::x2;
    /// Constructor for cloning \a p
    Eqv(Space* home, bool share, Eqv& p);
    /// Constructor for posting
    Eqv(Space* home, BVA b0 ,BVB b1, BVC b2);
  public:
    /// Copy propagator during cloning
    virtual Actor* copy(Space* home, bool share);
    /// Perform propagation
    virtual ExecStatus propagate(Space* home);
    /// Post propagator \f$ b_0 \Leftrightarrow b_1 = b_2 \f$ (equivalence)
    static  ExecStatus post(Space* home, BVA b0, BVB b1, BVC b2);
  };

}}}

#include "gecode/int/bool/base.icc"
#include "gecode/int/bool/eq.icc"
#include "gecode/int/bool/or.icc"
#include "gecode/int/bool/eqv.icc"

#endif

// STATISTICS: int-prop

