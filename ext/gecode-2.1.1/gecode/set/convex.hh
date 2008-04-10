/* -*- mode: C++; c-basic-offset: 2; indent-tabs-mode: nil -*- */
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

#ifndef __GECODE_SET_CONVEX_HH__
#define __GECODE_SET_CONVEX_HH__

#include "gecode/set.hh"

namespace Gecode { namespace Set { namespace Convex {

  /**
   * \namespace Gecode::Set::Convex
   * \brief Propagators for convexity
   */

  /**
   * \brief %Propagator for the convex constraint
   *
   * Requires \code #include "gecode/set/convex.hh" \endcode
   * \ingroup FuncSetProp
   */

  class Convex : public UnaryPropagator<SetView,PC_SET_ANY> {
  protected:
    /// Constructor for cloning \a p
    Convex(Space* home, bool share, Convex& p);
    /// Constructor for posting
    Convex(Space* home, SetView);
  public:
    /// Copy propagator during cloning
    GECODE_SET_EXPORT virtual Actor*      copy(Space* home,bool);
    /// Perform propagation
    GECODE_SET_EXPORT virtual ExecStatus  propagate(Space* home, ModEventDelta med);
    /// Post propagator that propagates that \a x is convex 
    static  ExecStatus  post(Space* home,SetView x);
    /// Specification for this propagator
    GECODE_SET_EXPORT
    virtual Reflection::ActorSpec spec(const Space* home,
                                        Reflection::VarMap& m) const;
    /// Post using specification
    static void post(Space* home, Reflection::VarMap& vars,
                     const Reflection::ActorSpec& spec);
    /// Name of this propagator
    static Support::Symbol ati(void);
  };

  /**
   * \brief %Propagator for the convex hull constraint
   *
   * Requires \code #include "gecode/set/convex.hh" \endcode
   * \ingroup FuncSetProp
   */

  class ConvexHull : public BinaryPropagator<SetView,PC_SET_ANY> {
  protected:
    /// Constructor for cloning \a p
    ConvexHull(Space* home, bool share, ConvexHull&);
    /// Constructor for posting
    ConvexHull(Space* home, SetView, SetView);
  public:
    /// Copy propagator during cloning
    GECODE_SET_EXPORT virtual Actor*  copy(Space* home,bool);
    /// Perform propagation
    GECODE_SET_EXPORT virtual ExecStatus  propagate(Space* home, ModEventDelta med);
    /// Post propagator that propagates that \a y is the convex hull of \a x
    static  ExecStatus  post(Space* home,SetView x,SetView y);
    /// Specification for this propagator
    GECODE_SET_EXPORT
    virtual Reflection::ActorSpec spec(const Space* home,
                                        Reflection::VarMap& m) const;
    /// Post using specification
    static void post(Space* home, Reflection::VarMap& vars,
                     const Reflection::ActorSpec& spec);
    /// Name of this propagator
    static Support::Symbol ati(void);
  };


}}}

#include "gecode/set/convex/conv.icc"
#include "gecode/set/convex/hull.icc"

#endif

// STATISTICS: set-prop
