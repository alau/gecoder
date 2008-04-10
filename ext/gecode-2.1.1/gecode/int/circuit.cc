/* -*- mode: C++; c-basic-offset: 2; indent-tabs-mode: nil -*- */
/*
 *  Main authors:
 *     Christian Schulte <schulte@gecode.org>
 *
 *  Copyright:
 *     Christian Schulte, 2006
 *
 *  Last modified:
 *     $Date: 2007-08-21 11:39:59 +0200 (Tue, 21 Aug 2007) $ by $Author: tack $
 *     $Revision: 4891 $
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

#include "gecode/int/circuit.hh"

namespace Gecode {

  void
  circuit(Space* home, const IntVarArgs& x, IntConLevel icl, PropKind) {
    using namespace Int;
    if (x.same())
      throw ArgumentSame("Int::circuit");
    if (home->failed()) return;
    if (x.size() == 0)
      return;
    ViewArray<IntView> xv(home,x);
    if (icl == ICL_DOM) {
      GECODE_ES_FAIL(home,Circuit::Dom<IntView>::post(home,xv));
    } else {
      GECODE_ES_FAIL(home,Circuit::Val<IntView>::post(home,xv));
    }
  }

  GECODE_REGISTER1(Int::Circuit::Dom<Int::IntView>);
  GECODE_REGISTER1(Int::Circuit::Val<Int::IntView>);

}

// STATISTICS: int-post
