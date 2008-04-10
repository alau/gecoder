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
 *     $Date: 2008-01-31 18:29:16 +0100 (Thu, 31 Jan 2008) $ by $Author: tack $
 *     $Revision: 6017 $
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

#include "gecode/set/sequence.hh"

namespace Gecode { namespace Set { namespace Sequence {

  /*
   * "Sequence" propagator
   *
   */

  Actor*
  Seq::copy(Space* home, bool share) {
    return new (home) Seq(home,share,*this);
  }

  Support::Symbol
  Seq::ati(void) {
    return Support::Symbol("Gecode::Set::Sequence::Sequence");
  }

  Reflection::ActorSpec
  Seq::spec(const Space* home, Reflection::VarMap& m) const {
    return NaryPropagator<SetView, PC_SET_ANY>::spec(home, m, ati());
  }

  void
  Seq::post(Space* home, Reflection::VarMap& vars,
             const Reflection::ActorSpec& spec) {
    spec.checkArity(1);
    ViewArray<SetView> x0(home, vars, spec[0]);
    (void) new (home) Seq(home, x0);
  }

  ExecStatus
  Seq::propagate(Space* home, ModEventDelta) {
    bool modified = false;
    bool assigned;
    do {
      assigned = false; modified = false;
      GECODE_ES_CHECK(propagateSeq(home, modified, assigned, x));
    } while (assigned || modified);

    for (int i=x.size(); i--;)
      if (!x[i].assigned())
        return ES_FIX;

    return ES_SUBSUMED(this,home);
  }

}}}

// STATISTICS: set-prop
