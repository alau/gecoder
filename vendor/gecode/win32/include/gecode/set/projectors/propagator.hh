/* -*- mode: C++; c-basic-offset: 2; indent-tabs-mode: nil -*- */
/*
 *  Main authors:
 *     Guido Tack <tack@gecode.org>
 *
 *  Copyright:
 *     Guido Tack, 2006
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

#ifndef __GECODE_GENERATOR_PROJECOTRS_HH
#define __GECODE_GENERATOR_PROJECTORS_HH

#include "gecode/set/projectors.hh"

/**
 * \namespace Gecode::Set::Projection
 * \brief Support for set projectors
 */

namespace Gecode { namespace Set { namespace Projection {

  /**
   * \brief Nary projection propagator
   */
  template <bool negated>
  class NaryProjection : public Propagator {
  protected:
    /// Array of views
    ViewArray<SetView> x;
    /// Array of PropConds
    SharedArray<PropCond> pc;
    /// The projector set to propagate
    ProjectorSet ps;
    /// Constructor for cloning \a p
    NaryProjection(Space* home, bool share, NaryProjection& p);
    /// Constructor for creation
    NaryProjection(Space* home, ViewArray<SetView>& x, ProjectorSet& ps);
  public:
    /// Cost function
    virtual PropCost cost(ModEventDelta med) const;
    /// Delete propagator
    virtual size_t dispose(Space* home);
    /// Copy propagator during cloning
    virtual Actor*      copy(Space* home,bool);
    /// Perform propagation
    virtual ExecStatus propagate(Space* home, ModEventDelta med);
    /// Specification for this propagator
    GECODE_SET_EXPORT
    virtual Reflection::ActorSpec spec(const Space* home,
                                        Reflection::VarMap& m) const;
    /// Name of this propagator
    static Support::Symbol ati(void);
    static  ExecStatus post(Space* home, ViewArray<SetView>& x,
                            ProjectorSet& ps);
  };

  /**
   * \brief Reified Nary projection propagator
   */
  class ReNaryProjection : public Propagator {
  protected:
    /// Array of views
    ViewArray<SetView> x;
    /// Boolean control view
    Gecode::Int::BoolView b;
    /// The projector set to propagate
    ProjectorSet ps;
    /// Constructor for cloning \a p
    ReNaryProjection(Space* home, bool share, ReNaryProjection& p);
    /// Constructor for creation
    ReNaryProjection(Space* home,ViewArray<SetView>& x,
                     Gecode::Int::BoolView,
                     ProjectorSet& ps);
  public:
    /// Cost function
    virtual PropCost cost(ModEventDelta med) const;
    /// Delete propagator
    GECODE_SET_EXPORT virtual size_t dispose(Space* home);
    /// Copy propagator during cloning
    GECODE_SET_EXPORT virtual Actor* copy(Space* home,bool);
    /// Perform propagation
    GECODE_SET_EXPORT virtual ExecStatus propagate(Space* home, ModEventDelta med);
    /// Specification for this propagator
    GECODE_SET_EXPORT
    virtual Reflection::ActorSpec spec(const Space* home,
                                        Reflection::VarMap& m) const;
    /// Name of this propagator
    static Support::Symbol ati(void);
    GECODE_SET_EXPORT static  ExecStatus post(Space* home,
                                              ViewArray<SetView>& x,
                                              Gecode::Int::BoolView b,
                                              ProjectorSet& ps);
  };

  /**
   * \brief Nary cardinality projection propagator
   */
  class CardProjection : public Propagator {
  protected:
    /// Array of views
    ViewArray<SetView> x;
    /// Integer view for cardinality
    Gecode::Int::IntView i;
    /// Array of PropConds
    SharedArray<PropCond> pc;
    /// The projector to propagate
    Projector proj;
    /// Constructor for cloning \a p
    CardProjection(Space* home, bool share, CardProjection& p);
    /// Constructor for creation
    CardProjection(Space* home, ViewArray<SetView>& x,
                   Gecode::Int::IntView i, Projector& ps);
  public:
    /// Cost function
    virtual PropCost cost(ModEventDelta med) const;
    /// Delete propagator
    virtual size_t dispose(Space* home);
    /// Copy propagator during cloning
    virtual Actor*      copy(Space* home,bool);
    /// Perform propagation
    virtual ExecStatus propagate(Space* home, ModEventDelta med);
    /// Specification for this propagator
    GECODE_SET_EXPORT
    virtual Reflection::ActorSpec spec(const Space* home,
                                        Reflection::VarMap& m) const;
    /// Name of this propagator
    static Support::Symbol ati(void);
    static  ExecStatus post(Space* home, ViewArray<SetView>& x,
                            Gecode::Int::IntView i, Projector& p);
  };
  
}}}

#include "gecode/set/projectors/propagator/nary.icc"
#include "gecode/set/projectors/propagator/re-nary.icc"
#include "gecode/set/projectors/propagator/card.icc"
  
#endif

// STATISTICS: set-prop
