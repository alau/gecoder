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

#ifndef __GECODE_SET_INT_HH__
#define __GECODE_SET_INT_HH__

#include "gecode/set.hh"

namespace Gecode { namespace Set { namespace Int {

  /**
   * \namespace Gecode::Set::Int
   * \brief Propagators connecting set and int variables
   */

  /**
   * \brief %Propator for minimum element
   *
   * Requires \code #include "gecode/set/int.hh" \endcode
   * \ingroup FuncSetProp
   */
  class MinElement :
    public IntSetPropagator<SetView,PC_SET_ANY,Gecode::Int::PC_INT_BND> {
  protected:
    /// Constructor for cloning \a p
    MinElement(Space* home, bool share,MinElement& p);
    /// Constructor for posting
    MinElement(Space* home,SetView, Gecode::Int::IntView);
  public:
    /// Copy propagator during cloning
    GECODE_SET_EXPORT virtual Actor*      copy(Space* home,bool);
    /// Perform propagation
    GECODE_SET_EXPORT virtual ExecStatus propagate(Space* home);
    /// Post propagator for \a x is the minimal element of \a s 
    static ExecStatus post(Space* home,SetView s, Gecode::Int::IntView x);
  };

  /**
   * \brief %Propator for maximum element
   *
   * Requires \code #include "gecode/set/int.hh" \endcode
   * \ingroup FuncSetProp
   */
  class MaxElement :
    public IntSetPropagator<SetView,PC_SET_ANY,Gecode::Int::PC_INT_BND> {
  protected:
    /// Constructor for cloning \a p
    MaxElement(Space* home, bool share,MaxElement& p);
    /// Constructor for posting
    MaxElement(Space* home,SetView, Gecode::Int::IntView);
  public:
    /// Copy propagator during cloning
    GECODE_SET_EXPORT virtual Actor*      copy(Space* home,bool);
    /// Perform propagation
    GECODE_SET_EXPORT virtual ExecStatus propagate(Space* home);
    /// Post propagator for \a x is the largest element of \a s 
    static ExecStatus post(Space* home,SetView s, Gecode::Int::IntView x);
  };

  /**
   * \brief %Propagator for cardinality
   *
   * Requires \code #include "gecode/set/int.hh" \endcode
   * \ingroup FuncSetProp
   */
  class Card :
    public IntSetPropagator<SetView,PC_SET_CARD,Gecode::Int::PC_INT_BND> {
  protected:
    /// Constructor for cloning \a p
    Card(Space* home, bool share,Card& p);
    /// Constructor for posting
    Card(Space* home,SetView, Gecode::Int::IntView);
  public:
    /// Copy propagator during cloning
    GECODE_SET_EXPORT virtual Actor*      copy(Space* home,bool);
    /// Perform propagation
    GECODE_SET_EXPORT virtual ExecStatus propagate(Space* home);
    /// Post propagator for \f$ |s|=x \f$ 
    static ExecStatus post(Space* home,SetView s, Gecode::Int::IntView x);
  };


  /**
   * \brief %Propagator for the match constraint
   *
   * Requires \code #include "gecode/set/int.hh" \endcode
   * \ingroup FuncSetProp
   */
  class Match : public Propagator {
  protected:
    /// SetView for the match
    SetView x0;
    /// IntViews that together form the set \a x0
    ViewArray< Gecode::Int::IntView > xs;

    /// Constructor for cloning \a p
    Match(Space* home, bool share,Match& p);
    /// Constructor for posting
    Match(Space* home,SetView, ViewArray< Gecode::Int::IntView >&);
  public:
    /// Copy propagator during cloning
    GECODE_SET_EXPORT virtual Actor*   copy(Space* home,bool);
    /// Cost function (defined as PC_LINEAR_LO)
    GECODE_SET_EXPORT virtual PropCost cost(void) const;
    /// Delete Propagator
    GECODE_SET_EXPORT virtual size_t dispose(Space* home);
    /// Perform propagation
    GECODE_SET_EXPORT virtual ExecStatus propagate(Space* home);
    /// Post propagator that propagates that \a s contains the \f$x_i\f$, which are sorted in non-descending order 
    static ExecStatus post(Space* home,SetView s,
			   ViewArray< Gecode::Int::IntView >& x);
  };

  /**
   * \brief %Propagator for channelling between variable-value-dual models
   *
   * Implements channelling constraints between IntVars and SetVars.
   * For IntVars \f$x_0,\dots,x_n\f$ and SetVars \f$y_0,\dots,y_m\f$ it
   * propagates the constraint \f$x_i=j \Leftrightarrow i\in y_j\f$.
   *
   * Can be used to implement the "channelling constraints" for disjoint with
   * cardinalities from
   *   "Disjoint, Partition and Intersection Constraints for
   *    Set and Multiset Variables"
   *    Christian Bessiere, Emmanuel Hebrard, Brahim Hnich, Toby Walsh
   *    CP 2004
   *
   * Requires \code #include "gecode/set/int.hh" \endcode
   * \ingroup FuncSetProp
   */
  class Channel : public Propagator {
  protected:
    /// IntViews, \f$x_i\f$ reflects which set contains element \f$i\f$
    ViewArray< Gecode::Int::IntView > xs;
    /// SetViews that are constrained to be disjoint
    ViewArray< SetView > ys;

    /// Constructor for cloning \a p
    Channel(Space* home, bool share,Channel& p);
    /// Constructor for posting
    Channel(Space* home,ViewArray< Gecode::Int::IntView >&,
	    ViewArray< SetView >&);
  public:
    /// Copy propagator during cloning
    GECODE_SET_EXPORT virtual Actor*   copy(Space* home,bool);
    /// Cost function (defined as PC_QUADRATIC_LO)
    GECODE_SET_EXPORT virtual PropCost cost(void) const;
    /// Delete propagator and return its size
    GECODE_SET_EXPORT virtual size_t dispose(Space* home);
    /// Perform propagation
    GECODE_SET_EXPORT virtual ExecStatus propagate(Space* home);
    /// Post propagator for \f$x_i=j \Leftrightarrow i\in y_j\f$
    static ExecStatus post(Space* home,ViewArray< Gecode::Int::IntView >& x,
                           ViewArray< SetView >& y);
  };

  /**
   * \brief %Propagator for weight of a set
   *
   * Requires \code #include "gecode/set/int.hh" \endcode
   * \ingroup FuncSetProp
   */
  class Weights : public Propagator {
  protected:
    /// List of elements in the upper bound
    Support::SharedArray<int> elements;
    /// Weights for the elements in the upper bound
    Support::SharedArray<int> weights;

    /// The set view
    SetView x;
    /// The integer view
    Gecode::Int::IntView y;

    /// Constructor for cloning \a p
    Weights(Space* home, bool share,Weights& p);
    /// Constructor for posting
    Weights(Space* home, const IntArgs&, const IntArgs&,
	    SetView, Gecode::Int::IntView);
  public:
    /// Copy propagator during cloning
    GECODE_SET_EXPORT virtual Actor*   copy(Space* home,bool);
    /// Cost function (defined as PC_LINEAR_LO)
    GECODE_SET_EXPORT virtual PropCost cost(void) const;
    /// Delete propagator and return its size
    GECODE_SET_EXPORT virtual size_t dispose(Space* home);
    /// Perform propagation
    GECODE_SET_EXPORT virtual ExecStatus propagate(Space* home);
    /// Post propagator for \f$\sum_{i\in x} weights_i = y \f$
    static ExecStatus post(Space* home,
			   const IntArgs& elements, const IntArgs& weights,
			   SetView x, Gecode::Int::IntView y);
  };

}}}

#include "gecode/set/int/minmax.icc"
#include "gecode/set/int/card.icc"
#include "gecode/set/int/match.icc"
#include "gecode/set/int/channel.icc"
#include "gecode/set/int/weights.icc"

#endif

// STATISTICS: set-prop

