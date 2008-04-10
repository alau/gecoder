/* -*- mode: C++; c-basic-offset: 2; indent-tabs-mode: nil -*- */
/*
 *  Main authors:
 *     Christian Schulte <schulte@gecode.org>
 *
 *  Copyright:
 *     Christian Schulte, 2007
 *
 *  Last modified:
 *     $Date: 2008-02-22 06:59:17 +0100 (Fri, 22 Feb 2008) $ by $Author: schulte $
 *     $Revision: 6275 $
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

#include "gecode/int/rel.hh"
#include "gecode/int/bool.hh"

/**
 * \namespace Gecode::Int::Unshare
 * \brief Unsharing shared variables
 */

namespace Gecode { 

 namespace Int { namespace Unshare {

    /// Sort order for variables
    template<class Var>
    class VarPtrLess {
    public:
      forceinline bool 
      operator()(const Var* a, const Var* b) {
        return before(*a,*b);
      }
    };
    
    
    /// Return a fresh yet equal integer variable
    forceinline ExecStatus
    link(Space* home, IntVar** x, int n, IntConLevel icl) {
      if (n > 2) {
        ViewArray<IntView> y(home,n);
        y[0]=*x[0];
        for (int i=1; i<n; i++) {
          x[i]->init(home,x[0]->min(),x[0]->max()); y[i]=*x[i];
        }
        if ((icl == ICL_DOM) || (icl == ICL_DEF)) {
          GECODE_ES_CHECK(Rel::NaryEqDom<IntView>::post(home,y));
        } else {
          GECODE_ES_CHECK(Rel::NaryEqBnd<IntView>::post(home,y));
        }
      } else if (n == 2) {
        IntVar z(home,x[0]->min(),x[0]->max());
        *x[1]=z;
        if ((icl == ICL_DOM) || (icl == ICL_DEF)) {
          GECODE_ES_CHECK((Rel::EqDom<IntView,IntView>::post
                           (home,*x[0],*x[1])));
        } else {
          GECODE_ES_CHECK((Rel::EqBnd<IntView,IntView>::post
                           (home,*x[0],*x[1])));
        }
      }
      return ES_OK;
    }
    
    /// Return a fresh yet equal Boolean variable
    forceinline ExecStatus
    link(Space* home, BoolVar** x, int n, IntConLevel) {
      if (n > 2) {
        ViewArray<BoolView> y(home,n);
        y[0]=*x[0];
        for (int i=1; i<n; i++) {
          x[i]->init(home,0,1); y[i]=*x[i];
        }
        GECODE_ES_CHECK(Bool::NaryEq<BoolView>::post(home,y));
      } else if (n == 2) {
        x[1]->init(home,0,1);
        GECODE_ES_CHECK((Bool::Eq<BoolView,BoolView>::post(home,*x[0],*x[1])));
      }
      return ES_OK;
    }
    
    /// Replace unassigned shared variables by fresh, yet equal variables
    template <class Var>
    forceinline ExecStatus 
    unshare(Space* home, VarArgArray<Var>& x, IntConLevel icl) {
      int n=x.size();
      if (n < 2)
        return ES_OK;

      GECODE_AUTOARRAY(Var*,y,n);
      for (int i=n; i--; )
        y[i]=&x[i];

      VarPtrLess<Var> vpl;
      Support::quicksort<Var*,VarPtrLess<Var> >(y,n,vpl);

      // Replace all shared variables with new and equal variables
      for (int i=0; i<n;) {
        int j=i++;
        while ((i<n) && same(*y[j],*y[i]))
          i++;
        if (!y[j]->assigned())
          link(home,&y[j],i-j,icl);
      }
      return ES_OK;
    }
    
  }}

  void 
  unshare(Space* home, IntVarArgs& x, IntConLevel icl, PropKind) {
    if (home->failed()) return;
    GECODE_ES_FAIL(home,Int::Unshare::unshare<IntVar>(home,x,icl));
  }

  void 
  unshare(Space* home, BoolVarArgs& x, IntConLevel, PropKind) {
    if (home->failed()) return;
    GECODE_ES_FAIL(home,Int::Unshare::unshare<BoolVar>(home,x,ICL_DEF));
  }

}

// STATISTICS: int-post
