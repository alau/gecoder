/* -*- mode: C++; c-basic-offset: 2; indent-tabs-mode: nil -*- */
/*
 *  Main authors:
 *     Patrick Pekczynski <pekczynski@ps.uni-sb.de>
 *
 *  Copyright:
 *     Patrick Pekczynski, 2006
 *
 *  Last modified:
 *     $Date: 2007-09-18 15:42:41 +0200 (Tue, 18 Sep 2007) $ by $Author: tack $
 *     $Revision: 5046 $
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

  namespace CpltSet { namespace Distinct {

    /**
     * \namespace Gecode::CpltSet::Distinct
     * \brief Propagators for distinctness constraints
     */

    template <class View>
    void distinct(Space* home, ViewArray<View>& x) {
  
      int n = x.size();
      // build partition
      bdd d0 = bdd_true();     

      unsigned int width = x[0].tableWidth();

      for (int i = 0; i < n - 1; i++) {
        for (int j = i + 1; j < n; j++) {
          bdd nq = bdd_false();
          for (unsigned int k = 0; k < width; k++) {
            nq |= !(x[i].element(k) % x[j].element(k));
          }
          d0 &= nq;
        }
      } 

      GECODE_ES_FAIL(home, NaryCpltSetPropagator<View>::post(home, x, d0));
    }    
  }}

  void distinct(Space* home, const CpltSetVarArgs& x) {
    if (home->failed()) return;
    ViewArray<CpltSetView> y(home, x);
    Distinct::distinct(home, y);
  }

}

// STATISTICS: cpltset-post
