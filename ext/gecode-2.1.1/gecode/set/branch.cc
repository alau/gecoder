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
 *     $Date: 2008-02-28 14:12:40 +0100 (Thu, 28 Feb 2008) $ by $Author: tack $
 *     $Revision: 6344 $
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

#include "gecode/set/branch.hh"

namespace Gecode {

  using namespace Set;

  void
  branch(Space* home, const SetVarArgs& xa, 
         SetVarBranch vars, SetValBranch vals) {
    ViewArray<SetView> x(home,xa);
    switch (vars) {
    case SET_VAR_NONE:
      if (home->failed()) return;
      Branch::create<Branch::ByNone>(home,x,vals); break;
    case SET_VAR_MIN_CARD:
      if (home->failed()) return;
      Branch::create<Branch::ByMinCard>(home,x,vals); break;
    case SET_VAR_MAX_CARD:
      if (home->failed()) return;
      Branch::create<Branch::ByMaxCard>(home,x,vals); break;
    case SET_VAR_MIN_UNKNOWN_ELEM:
      if (home->failed()) return;
      Branch::create<Branch::ByMinUnknown>(home,x,vals); break;
    case SET_VAR_MAX_UNKNOWN_ELEM:
      if (home->failed()) return;
      Branch::create<Branch::ByMaxUnknown>(home,x,vals); break;
    default:
      throw UnknownBranching("Set::branch");
    }
  }

}

// STATISTICS: set-post

