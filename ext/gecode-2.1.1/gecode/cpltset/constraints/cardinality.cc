/* -*- mode: C++; c-basic-offset: 2; indent-tabs-mode: nil -*- */
/*
 *  Main authors:
 *     Patrick Pekczynski <pekczynski@ps.uni-sb.de>
 *
 *  Copyright:
 *     Patrick Pekczynski, 2006
 *
 *  Last modified:
 *     $Date: 2008-02-01 14:48:35 +0100 (Fri, 01 Feb 2008) $ by $Author: tack $
 *     $Revision: 6039 $
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

#include "gecode/cpltset.hh"
#include "gecode/cpltset/propagators.hh"

using namespace Gecode::CpltSet;

namespace Gecode {

  void
  cardinality(Space* home, CpltSetVar x, unsigned int l, unsigned int u) {
    if (home->failed()) return;
    Set::Limits::check(l, "CpltSet::cardinality");
    Set::Limits::check(u, "CpltSet::cardinality");

    ViewArray<CpltSetView> bv(home, 1);
    bv[0] = x;
    unsigned int off = bv[0].offset();
    unsigned int range = bv[0].tableWidth();

    bdd c = cardcheck(range, off, static_cast<int> (l), static_cast<int> (u));

    CpltSetView v(x);
    GECODE_ME_FAIL(home, v.cardinality(home, l, u));
  }

  void
  cardinality(Space* home, CpltSetVar x, unsigned int c) {
    cardinality(home, x, c, c);
  }

}

// STATISTICS: cpltset-post
