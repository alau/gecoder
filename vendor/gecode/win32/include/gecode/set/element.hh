/* -*- mode: C++; c-basic-offset: 2; indent-tabs-mode: nil -*- */
/*
 *  Main authors:
 *     Guido Tack <tack@gecode.org>
 *     Christian Schulte <schulte@gecode.org>
 *
 *  Copyright:
 *     Guido Tack, 2004
 *     Christian Schulte, 2004
 *
 *  Last modified:
 *     $Date: 2008-07-11 10:35:42 +0200 (Fri, 11 Jul 2008) $ by $Author: tack $
 *     $Revision: 7339 $
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

#ifndef __GECODE_SET_SELECT_HH__
#define __GECODE_SET_SELECT_HH__

#include "gecode/set.hh"

#include "gecode/set/element/idxarray.hh"
#include "gecode/set/rel.hh"
#include "gecode/set/rel-op.hh"

namespace Gecode { namespace Set { namespace Element {

  /**
   * \namespace Gecode::Set::Element
   * \brief %Set element propagators
   */

  /**
   * \brief %Propagator for element with intersection
   *
   * Requires \code #include "gecode/set/element.hh" \endcode
   * \ingroup FuncSetProp
   */
  template <class SView, class RView>
  class ElementIntersection :
    public Propagator {
  protected:
    IntSet universe;
    SView x0;
    IdxViewArray<SView> iv;
    RView x1;

    /// Constructor for cloning \a p
    ElementIntersection(Space* home, bool share,ElementIntersection& p);
    /// Constructor for posting
    ElementIntersection(Space* home,SView,IdxViewArray<SView>&,RView,
                       const IntSet& universe);
  public:
    /// Copy propagator during cloning
    virtual Actor*      copy(Space* home,bool);
    virtual PropCost    cost(ModEventDelta med) const;
    /// Delete propagator and return its size
    virtual size_t dispose(Space* home);
    /// Perform propagation
    virtual ExecStatus  propagate(Space* home, ModEventDelta med);
    /// Specification for this propagator
    virtual Reflection::ActorSpec spec(const Space* home,
                                        Reflection::VarMap& m) const;
    /// Post using specification
    static void post(Space* home, Reflection::VarMap& vars,
                     const Reflection::ActorSpec& spec);
    /// Name of this propagator
    static Support::Symbol ati(void);
    /** Post propagator for \f$ z=\bigcap\langle x_0,\dots,x_{n-1}\rangle[y] \f$ using \a u as universe
     *
     * If \a y is empty, \a z will be constrained to be the given universe
     * \a u (as an empty intersection is the universe).
     */
    static  ExecStatus  post(Space* home,SView z,IdxViewArray<SView>& x,
                             RView y, const IntSet& u);
  };

  /**
   * \brief %Propagator for element with union
   *
   * Requires \code #include "gecode/set/element.hh" \endcode
   * \ingroup FuncSetProp
   */
  template <class SView, class RView>
  class ElementUnion :
    public Propagator {
  protected:
    SView x0;
    IdxViewArray<SView> iv;
    RView x1;

    /// Constructor for cloning \a p
    ElementUnion(Space* home, bool share,ElementUnion& p);
    /// Constructor for posting
    ElementUnion(Space* home,SView,IdxViewArray<SView>&,RView);
  public:
    /// Copy propagator during cloning
    virtual Actor*      copy(Space* home,bool);
    virtual PropCost    cost(ModEventDelta med) const;
    /// Delete propagator and return its size
    virtual size_t dispose(Space* home);
    /// Perform propagation
    virtual ExecStatus  propagate(Space* home, ModEventDelta med);
    /// Specification for this propagator
    virtual Reflection::ActorSpec spec(const Space* home,
                                        Reflection::VarMap& m) const;
    /// Post using specification
    static void post(Space* home, Reflection::VarMap& vars,
                     const Reflection::ActorSpec& spec);
    /// Name of this propagator
    static Support::Symbol ati(void);
    /** Post propagator for \f$ z=\bigcup\langle x_0,\dots,x_{n-1}\rangle[y] \f$
     *
     * If \a y is empty, \a z will be constrained to be empty
     * (as an empty union is the empty set).
     */
    static  ExecStatus  post(Space* home,SView z,IdxViewArray<SView>& x,
                             RView y);
  };

  /**
   * \brief %Propagator for element with union of constant sets
   *
   * Requires \code #include "gecode/set/element.hh" \endcode
   * \ingroup FuncSetProp
   */
  template <class SView, class RView>
  class ElementUnionConst :
    public Propagator {
  protected:
    SView x0;
    SharedArray<IntSet> iv;
    RView x1;

    /// Constructor for cloning \a p
    ElementUnionConst(Space* home, bool share,ElementUnionConst& p);
    /// Constructor for posting
    ElementUnionConst(Space* home,SView,SharedArray<IntSet>&,RView);
  public:
    /// Copy propagator during cloning
    virtual Actor*      copy(Space* home,bool);
    virtual PropCost    cost(ModEventDelta med) const;
    /// Delete propagator and return its size
    virtual size_t dispose(Space* home);
    /// Perform propagation
    virtual ExecStatus  propagate(Space* home, ModEventDelta med);
    /// Specification for this propagator
    virtual Reflection::ActorSpec spec(const Space* home,
                                        Reflection::VarMap& m) const;
    /// Post using specification
    static void post(Space* home, Reflection::VarMap& vars,
                     const Reflection::ActorSpec& spec);
    /// Name of this propagator
    static Support::Symbol ati(void);
    /** Post propagator for \f$ z=\bigcup\langle s_0,\dots,s_{n-1}\rangle[y] \f$
     *
     * If \a y is empty, \a z will be constrained to be empty
     * (as an empty union is the empty set).
     */
    static  ExecStatus  post(Space* home,SView z,SharedArray<IntSet>& x,
                             RView y);
  };

  /**
   * \brief %Propagator for element with disjointness
   *
   * Requires \code #include "gecode/set/element.hh" \endcode
   * \ingroup FuncSetProp
   */
  class ElementDisjoint :
    public Propagator {
  protected:
    IdxViewArray<SetView> iv;
    SetView x1;

    /// Constructor for cloning \a p
    ElementDisjoint(Space* home, bool share,ElementDisjoint& p);
    /// Constructor for posting
    ElementDisjoint(Space* home,IdxViewArray<SetView>&,SetView);
  public:
    /// Copy propagator during cloning
    GECODE_SET_EXPORT virtual Actor*      copy(Space* home,bool);
    GECODE_SET_EXPORT virtual PropCost    cost(ModEventDelta med) const;
    /// Delete propagator and return its size
    GECODE_SET_EXPORT virtual size_t dispose(Space* home);
    /// Perform propagation
    GECODE_SET_EXPORT virtual ExecStatus  propagate(Space* home, ModEventDelta med);
    /// Specification for this propagator
    virtual Reflection::ActorSpec spec(const Space* home,
                                        Reflection::VarMap& m) const;
    /// Post using specification
    static void post(Space* home, Reflection::VarMap& vars,
                     const Reflection::ActorSpec& spec);
    /// Name of this propagator
    static Support::Symbol ati(void);
    /// Post propagator for \f$ \parallel\langle x_0,\dots,x_{n-1}\rangle[y] \f$ 
    static  ExecStatus  post(Space* home,IdxViewArray<SetView>& x,SetView y);
  };

}}}

#include "gecode/set/element/inter.icc"
#include "gecode/set/element/union.icc"
#include "gecode/set/element/unionConst.icc"
#include "gecode/set/element/disjoint.icc"

#endif

// STATISTICS: set-prop

