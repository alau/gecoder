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

  namespace CpltSet { namespace Select {

    /**
     * \namespace Gecode::CpltSet::Select
     * \brief Propagators for selection constraints
     */

    template <class View>
    forceinline void 
    selectNonEmptySub_post(Space* home, ViewArray<View> x) {
      if (home->failed()) return;
      int n = x.size() - 2;
      int s = n;
      int t = n + 1;
      // just assume that they all have the same range
    
      unsigned int xrange = x[0].tableWidth();

      // compute maximum value
      for (int i = n; i--; ) {
        if (x[i].tableWidth() > xrange) {
          xrange = x[i].tableWidth();
        }
      }

      if (x[t].tableWidth() > xrange) {
        int a = x[t].initialLubMin() + xrange;
        int b = x[t].initialLubMin() + x[t].tableWidth();
        GECODE_ME_FAIL(home, x[t].exclude(home, a, b));
      } 
    
      bdd d0 = bdd_true();

      // restrict selector variable s to be \f$ s\subseteq \{0, n - 1\}\f$
      // int range = xrange;
      int shift = 0;
      if (x[s].initialLubMin() < 0) {
        shift = 0 - x[s].initialLubMin();
      }

      Iter::Ranges::Singleton idx(0, n - 1);
      GECODE_ME_FAIL(home, x[s].intersectI(home, idx));

      for (int j = 0; j < n; j++) {    
        bdd subset = bdd_true();
        bdd inter  = bdd_false();
        for (unsigned int k = 0; k < xrange; k++) {
          subset &= (x[j].element(k) >>= x[t].element(k));
          inter  |= (x[j].element(k) & x[t].element(k));
        }     
        d0 &= (x[s].element(j + shift) % (subset & inter));
      }
    
      GECODE_ES_FAIL(home, NaryCpltSetPropagator<View>::post(home, x, d0));
    }

    forceinline void 
    selectNonEmptySub_con(Space* home, const CpltSetVarArgs& x,
                        const CpltSetVar& s, const CpltSetVar& t) {
      int n = x.size();
      int m = n + 2;
      ViewArray<CpltSetView> bv(home, m);
      for (int i = 0; i < n; i++) {
        bv[i] = x[i];
      }
      bv[n] = s;
      bv[n + 1] = t;
      selectNonEmptySub_post(home, bv);    
    }

  }} // end namespace CpltSet::Select;
  
  using namespace CpltSet::Select;

  void selectNonEmptySub(Space* home, const CpltSetVarArgs& x, CpltSetVar s, 
                         CpltSetVar t) {
    selectNonEmptySub_con(home, x, s, t);
  }

}

// STATISTICS: cpltset-post
