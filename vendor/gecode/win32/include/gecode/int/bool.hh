/* -*- mode: C++; c-basic-offset: 2; indent-tabs-mode: nil -*- */
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
 *     $Date: 2008-01-29 13:37:51 +0100 (Tue, 29 Jan 2008) $ by $Author: tack $
 *     $Revision: 5993 $
 *
 *  This file is part of Gecode, the generic constraint
 *  development environment:
 *     http://www.gecode.org
 *
 *  Permission is hereby granted, free of charge, to any person obtaining
 *  a copy of this software and associated documentation files (the
 *  "Software"), to deal in the Software without restriction, including
 *  without limitation the rights to use, copy, modify, merge, publish,
 *  distribute, sublicense, and/or sell copies of the Software, and to
 *  permit persons to whom the Software is furnished to do so, subject to
 *  the following conditions:
 *
 *  The above copyright notice and this permission notice shall be
 *  included in all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 *  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 *  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 *  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 *  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 *  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 *  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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
    /// Specification for this propagator
    Reflection::ActorSpec spec(const Space* home, Reflection::VarMap& m, 
                                const Support::Symbol& name) const;
  public:
    /// Cost function (defined as PC_UNARY_LO)
    virtual PropCost cost(ModEventDelta med) const;
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
    /// Specification for this propagator
    Reflection::ActorSpec spec(const Space* home, Reflection::VarMap& m,
                                const Support::Symbol& name) const;
  public:
    /// Constructor for rewriting \a p during cloning
    BoolTernary(Space* home, bool share, Propagator& p,
                BVA b0, BVB b1, BVC b2);
    /// Cost function (defined as PC_BINARY_LO)
    virtual PropCost cost(ModEventDelta med) const;
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
    virtual ExecStatus propagate(Space* home, ModEventDelta med);
    /// Post propagator \f$ b_0 = b_1\f$
    static  ExecStatus post(Space* home, BVA b0, BVB b1);
    /// Specification for this propagator
    virtual Reflection::ActorSpec spec(const Space* home,
                                        Reflection::VarMap& m) const;
    /// Post using specification
    static void post(Space* home, Reflection::VarMap& vars,
                     const Reflection::ActorSpec& spec);
    /// Name of this propagator
    static Support::Symbol ati(void);
  };


  /**
   * \brief n-ary Boolean equality propagator
   *
   * Requires \code #include "gecode/int/bool.hh" \endcode
   * \ingroup FuncIntProp
   */
  template<class BV>
  class NaryEq : public NaryPropagator<BV,PC_BOOL_VAL> {
  protected:
    using NaryPropagator<BV,PC_BOOL_VAL>::x;
    /// Constructor for posting
    NaryEq(Space* home, ViewArray<BV>& x);
    /// Constructor for cloning \a p
    NaryEq(Space* home, bool share, NaryEq& p);
  public:
    /// Copy propagator during cloning
    virtual Actor* copy(Space* home, bool share);
    /// Cost function (defined as PC_UNARY_LO)
    virtual PropCost cost(ModEventDelta med) const;
    /// Perform propagation
    virtual ExecStatus propagate(Space* home, ModEventDelta med);
    /// Post propagator \f$ x_0 = x_1=\ldots =x_{|x|-1}\f$
    static  ExecStatus post(Space* home, ViewArray<BV>& x);
    /// Post propagator for specification
    static void post(Space* home, Reflection::VarMap& vars,
                     const Reflection::ActorSpec& spec);
    /// Specification for this propagator
    virtual Reflection::ActorSpec spec(const Space* home,
                                        Reflection::VarMap& m) const;
    /// Name of this propagator
    static Support::Symbol ati(void);
  };


  /**
   * \brief Boolean less or equal propagator
   *
   * Requires \code #include "gecode/int/bool.hh" \endcode
   * \ingroup FuncIntProp
   */
  template<class BV>
  class Lq : public BoolBinary<BV,BV> {
  protected:
    using BoolBinary<BV,BV>::x0;
    using BoolBinary<BV,BV>::x1;
    /// Constructor for posting
    Lq(Space* home, BV b0, BV b1);
    /// Constructor for cloning \a p
    Lq(Space* home, bool share, Lq& p);
  public:
    /// Copy propagator during cloning
    virtual Actor* copy(Space* home, bool share);
    /// Perform propagation
    virtual ExecStatus propagate(Space* home, ModEventDelta med);
    /// Post propagator \f$ b_0 \leq b_1\f$
    static  ExecStatus post(Space* home, BV b0, BV b1);
    /// Specification for this propagator
    virtual Reflection::ActorSpec spec(const Space* home,
                                        Reflection::VarMap& m) const;
    /// Post using specification
    static void post(Space* home, Reflection::VarMap& vars,
                     const Reflection::ActorSpec& spec);
    /// Name of this propagator
    static Support::Symbol ati(void);
  };


  /**
   * \brief Boolean less propagator
   *
   * Requires \code #include "gecode/int/bool.hh" \endcode
   * \ingroup FuncIntProp
   */
  template<class BV>
  class Le {
  public:
    /// Post propagator \f$ b_0 < b_1\f$
    static  ExecStatus post(Space* home, BV b0, BV b1);
  };


  /**
   * \brief Binary Boolean disjunction propagator (true)
   *
   * Requires \code #include "gecode/int/bool.hh" \endcode
   * \ingroup FuncIntProp
   */
  template<class BVA, class BVB>
  class BinOrTrue : public BoolBinary<BVA,BVB> {
  protected:
    using BoolBinary<BVA,BVB>::x0;
    using BoolBinary<BVA,BVB>::x1;
    /// Constructor for posting
    BinOrTrue(Space* home, BVA b0, BVB b1);
    /// Constructor for cloning \a p
    BinOrTrue(Space* home, bool share, BinOrTrue& p);
  public:
    /// Constructor for rewriting \a p during cloning
    BinOrTrue(Space* home, bool share, Propagator& p,
              BVA b0, BVB b1);
    /// Copy propagator during cloning
    virtual Actor* copy(Space* home, bool share);
    /// Perform propagation
    virtual ExecStatus propagate(Space* home, ModEventDelta med);
    /// Post propagator \f$ b_0 \lor b_1 = 1 \f$
    static  ExecStatus post(Space* home, BVA b0, BVB b1);
    /// Specification for this propagator
    virtual Reflection::ActorSpec spec(const Space* home,
                                        Reflection::VarMap& m) const;
    /// Post using specification
    static void post(Space* home, Reflection::VarMap& vars,
                     const Reflection::ActorSpec& spec);
    /// Name of this propagator
    static Support::Symbol ati(void);
  };

  /**
   * \brief Ternary Boolean disjunction propagator (true)
   *
   * Requires \code #include "gecode/int/bool.hh" \endcode
   * \ingroup FuncIntProp
   */
  template<class BV>
  class TerOrTrue : public BoolBinary<BV,BV> {
  protected:
    using BoolBinary<BV,BV>::x0;
    using BoolBinary<BV,BV>::x1;
    /// Boolean view without subscription
    BV x2;
    /// Constructor for posting
    TerOrTrue(Space* home, BV b0, BV b1, BV b2);
    /// Constructor for cloning \a p
    TerOrTrue(Space* home, bool share, TerOrTrue& p);
  public:
    /// Constructor for rewriting \a p during cloning
    TerOrTrue(Space* home, bool share, Propagator& p,
              BV b0, BV b1, BV b2);
    /// Copy propagator during cloning
    virtual Actor* copy(Space* home, bool share);
    /// Perform propagation
    virtual ExecStatus propagate(Space* home, ModEventDelta med);
    /// Post propagator \f$ b_0 \lor b_1 \lor b_2 = 1 \f$
    static  ExecStatus post(Space* home, BV b0, BV b1, BV b2);
    /// Delete propagator and return its size
    virtual size_t dispose(Space* home);
    /// Specification for this propagator
    virtual Reflection::ActorSpec spec(const Space* home,
                                        Reflection::VarMap& m) const;
    /// Post using specification
    static void post(Space* home, Reflection::VarMap& vars,
                     const Reflection::ActorSpec& spec);
    /// Name of this propagator
    static Support::Symbol ati(void);
  };

  /**
   * \brief Quarternary Boolean disjunction propagator (true)
   *
   * Requires \code #include "gecode/int/bool.hh" \endcode
   * \ingroup FuncIntProp
   */
  template<class BV>
  class QuadOrTrue : public BoolBinary<BV,BV> {
  protected:
    using BoolBinary<BV,BV>::x0;
    using BoolBinary<BV,BV>::x1;
    /// Boolean view without subscription
    BV x2;
    /// Boolean view without subscription
    BV x3;
    /// Constructor for posting
    QuadOrTrue(Space* home, BV b0, BV b1, BV b2, BV b3);
    /// Constructor for cloning \a p
    QuadOrTrue(Space* home, bool share, QuadOrTrue& p);
  public:
    /// Constructor for rewriting \a p during cloning
    QuadOrTrue(Space* home, bool share, Propagator& p,
               BV b0, BV b1, BV b2, BV b3);
    /// Copy propagator during cloning
    virtual Actor* copy(Space* home, bool share);
    /// Perform propagation
    virtual ExecStatus propagate(Space* home, ModEventDelta med);
    /// Post propagator \f$ b_0 \lor b_1 \lor b_2 \lor b_3 = 1 \f$
    static  ExecStatus post(Space* home, BV b0, BV b1, BV b2, BV b3);
    /// Specification for this propagator
    virtual Reflection::ActorSpec spec(const Space* home,
                                        Reflection::VarMap& m) const;
    /// Name of this propagator
    static Support::Symbol ati(void);
    /// Post using specification
    static void post(Space* home, Reflection::VarMap& vars,
                     const Reflection::ActorSpec& spec);
    /// Delete propagator and return its size
    virtual size_t dispose(Space* home);
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
    virtual ExecStatus propagate(Space* home, ModEventDelta med);
    /// Post propagator \f$ b_0 \lor b_1 = b_2 \f$
    static  ExecStatus post(Space* home, BVA b0, BVB b1, BVC b2);
    /// Specification for this propagator
    virtual Reflection::ActorSpec spec(const Space* home,
                                        Reflection::VarMap& m) const;
    /// Post using specification
    static void post(Space* home, Reflection::VarMap& vars,
                     const Reflection::ActorSpec& spec);
    /// Name of this propagator
    static Support::Symbol ati(void);
  };

  /**
   * \brief Boolean n-ary disjunction propagator
   *
   * Requires \code #include "gecode/int/bool.hh" \endcode
   * \ingroup FuncIntProp
   */
  template<class BV>
  class NaryOr : public NaryOnePropagator<BV,PC_BOOL_VAL> {
  protected:
    using NaryOnePropagator<BV,PC_BOOL_VAL>::x;
    using NaryOnePropagator<BV,PC_BOOL_VAL>::y;
    /// Constructor for posting
    NaryOr(Space* home,  ViewArray<BV>& b, BV c);
    /// Constructor for cloning \a p
    NaryOr(Space* home, bool share, NaryOr<BV>& p);
  public:
    /// Copy propagator during cloning
    virtual Actor* copy(Space* home, bool share);
    /// Perform propagation
    virtual ExecStatus propagate(Space* home, ModEventDelta med);
    /// Post propagator \f$ \bigvee_{i=0}^{|b|-1} b_i = c\f$
    static  ExecStatus post(Space* home, ViewArray<BV>& b, BV c);
    /// Specification for this propagator
    virtual Reflection::ActorSpec spec(const Space* home,
                                        Reflection::VarMap& m) const;
    /// Post using specification
    static void post(Space* home, Reflection::VarMap& vars,
                     const Reflection::ActorSpec& spec);
    /// Name of this propagator
    static Support::Symbol ati(void);
  };


  /**
   * \brief Boolean n-ary disjunction propagator (true)
   *
   * Requires \code #include "gecode/int/bool.hh" \endcode
   * \ingroup FuncIntProp
   */
  template<class BV>
  class NaryOrTrue : public BinaryPropagator<BV,PC_BOOL_VAL> {
  protected:
    using BinaryPropagator<BV,PC_BOOL_VAL>::x0;
    using BinaryPropagator<BV,PC_BOOL_VAL>::x1;
    /// Views not yet subscribed to
    ViewArray<BV> x;
    /// Update subscription
    ExecStatus resubscribe(Space* home, BV& x0, BV x1);
    /// Constructor for posting
    NaryOrTrue(Space* home,  ViewArray<BV>& b);
    /// Constructor for cloning \a p
    NaryOrTrue(Space* home, bool share, NaryOrTrue<BV>& p);
  public:
    /// Copy propagator during cloning
    virtual Actor* copy(Space* home, bool share);
    /// Cost function (defined as PC_LINEAR_LO)
    virtual PropCost cost(ModEventDelta med) const;
    /// Perform propagation
    virtual ExecStatus propagate(Space* home, ModEventDelta med);
    /// Post propagator \f$ \bigvee_{i=0}^{|b|-1} b_i = 0\f$
    static  ExecStatus post(Space* home, ViewArray<BV>& b);
    /// Specification for this propagator
    virtual Reflection::ActorSpec spec(const Space* home,
                                        Reflection::VarMap& m) const;
    /// Post using specification
    static void post(Space* home, Reflection::VarMap& vars,
                     const Reflection::ActorSpec& spec);
    /// Name of this propagator
    static Support::Symbol ati(void);
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
    virtual ExecStatus propagate(Space* home, ModEventDelta med);
    /// Post propagator \f$ b_0 \Leftrightarrow b_1 = b_2 \f$ (equivalence)
    static  ExecStatus post(Space* home, BVA b0, BVB b1, BVC b2);
    /// Specification for this propagator
    virtual Reflection::ActorSpec spec(const Space* home,
                                        Reflection::VarMap& m) const;
    /// Post using specification
    static void post(Space* home, Reflection::VarMap& vars,
                     const Reflection::ActorSpec& spec);
    /// Name of this propagator
    static Support::Symbol ati(void);
  };

}}}

#include "gecode/int/bool/base.icc"
#include "gecode/int/bool/eq.icc"
#include "gecode/int/bool/lq.icc"
#include "gecode/int/bool/or.icc"
#include "gecode/int/bool/eqv.icc"

#endif

// STATISTICS: int-prop

