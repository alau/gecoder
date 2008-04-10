/* -*- mode: C++; c-basic-offset: 2; indent-tabs-mode: nil -*- */
/*
 *  Main authors:
 *     Guido Tack <tack@gecode.org>
 *
 *  Contributing authors:
 *     Gabor Szokoli <szokoli@gecode.org>
 *
 *  Copyright:
 *     Guido Tack, 2004, 2005
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

#include "gecode/set.hh"
#include "gecode/set/rel.hh"

namespace Gecode {

  void
  dom(Space* home, SetVar s, SetRelType r, int i) {
    Set::Limits::check(i, "Set::dom");
    IntSet d(i,i);
    dom(home, s, r, d);
  }

  void
  dom(Space* home, SetVar s, SetRelType r, int i, int j) {
    Set::Limits::check(i, "Set::dom");
    Set::Limits::check(j, "Set::dom");
    IntSet d(i,j);
    dom(home, s, r, d);
  }

  void
  dom(Space* home, SetVar s, SetRelType r, const IntSet& is) {
    Set::Limits::check(is, "Set::dom");
    if (home->failed()) return;

    Set::SetView _s(s);

    switch(r) {
    case SRT_EQ:
      {
        if (is.size() == 1) {
          GECODE_ME_FAIL(home,_s.include(home, is.min(), is.max()));
          GECODE_ME_FAIL(home,_s.intersect(home, is.min(), is.max()));
        } else {
          IntSetRanges rd1(is);
          GECODE_ME_FAIL(home,_s.includeI(home, rd1));
          IntSetRanges rd2(is);
          GECODE_ME_FAIL(home,_s.intersectI(home, rd2));
        }
      }
      break;
    case SRT_DISJ:
      {
        if (is.size() == 1) {
          GECODE_ME_FAIL(home,_s.exclude(home, is.min(), is.max()));
        } else {
          IntSetRanges rd(is);
          GECODE_ME_FAIL(home,_s.excludeI(home, rd));
        }
      }
      break;
    case SRT_NQ:
      {
        Set::ConstantView cv(home, is);
        GECODE_ES_FAIL(home,
                       (Set::Rel::DistinctDoit<Set::SetView>::post(home, s, 
                                                                   cv)));
      }
      break;
    case SRT_SUB:
      {
         if (is.size() == 1) {
           GECODE_ME_FAIL(home,_s.intersect(home, is.min(), is.max()));
         } else {
          IntSetRanges rd(is);
          GECODE_ME_FAIL(home,_s.intersectI(home, rd));
         }
      }
      break;
    case SRT_SUP:
      {
        if (is.size() == 1) {
          GECODE_ME_FAIL(home,_s.include(home, is.min(), is.max()));
        } else {
          IntSetRanges rd(is);
          GECODE_ME_FAIL(home,_s.includeI(home, rd));
        }
      }
      break;
    case SRT_CMPL:
      {
        if (is.size() == 1) {
          GECODE_ME_FAIL(home,_s.exclude(home, is.min(), is.max()));
          GECODE_ME_FAIL(home,
                         _s.include(home,
                                    Set::Limits::min,
                                    is.min()-1) );
          GECODE_ME_FAIL(home,
                         _s.include(home, is.max()+1,
                                    Set::Limits::max) );
        } else {
          IntSetRanges rd1(is);
          Set::RangesCompl<IntSetRanges > rdC1(rd1);
          GECODE_ME_FAIL(home,_s.includeI(home, rdC1));
          IntSetRanges rd2(is);
          Set::RangesCompl<IntSetRanges > rdC2(rd2);
          GECODE_ME_FAIL(home,_s.intersectI(home, rdC2));
        }
      }
      break;
    }
  }

  void
  dom(Space* home, SetVar s, SetRelType r, int i, BoolVar b) {
    Set::Limits::check(i, "Set::dom");
    IntSet d(i,i);
    dom(home, s, r, d, b);
  }

  void
  dom(Space* home, SetVar s, SetRelType r, int i, int j, BoolVar b) {
    Set::Limits::check(i, "Set::dom");
    Set::Limits::check(j, "Set::dom");
    IntSet d(i,j);
    dom(home, s, r, d, b);
  }

  void
  dom(Space* home, SetVar s, SetRelType r, const IntSet& is, BoolVar b) {
    Set::Limits::check(is, "Set::dom");
    if (home->failed()) return;
    switch(r) {
    case SRT_EQ:
      {
        Set::ConstantView cv(home, is);
        GECODE_ES_FAIL(home,
                       (Set::Rel::ReEq<Set::SetView,
                        Set::ConstantView>::post(home, s, cv, b)));
      }
      break;
    case SRT_NQ:
      {
        BoolVar notb(home,0,1);
        rel(home, b, IRT_NQ, notb);
        Set::ConstantView cv(home, is);
        GECODE_ES_FAIL(home,
                       (Set::Rel::ReEq<Set::SetView,
                        Set::ConstantView>::post(home, s, cv, notb)));
      }
      break;
    case SRT_SUB:
      {
        Set::ConstantView cv(home, is);
        GECODE_ES_FAIL(home,
                       (Set::Rel::ReSubset<Set::SetView,Set::ConstantView>
                        ::post(home, s, cv, b)));
      }
      break;
    case SRT_SUP:
      {
        Set::ConstantView cv(home, is);
        GECODE_ES_FAIL(home,
                       (Set::Rel::ReSubset<Set::ConstantView,Set::SetView>
                        ::post(home, cv, s, b)));
      }
      break;
    case SRT_DISJ:
      {
        // x||y <=> b is equivalent to
        // ( y <= complement(x) and x<=complement(y) ) <=> b

        // compute complement of is
        IntSetRanges dr1(is);
        Set::RangesCompl<IntSetRanges > dc1(dr1);
        IntSet dcompl(dc1);
        Set::ConstantView cvcompl(home, dcompl);
        GECODE_ES_FAIL(home,
                       (Set::Rel::ReSubset<Set::SetView,Set::ConstantView>
                        ::post(home, s, cvcompl, b)));
      }
      break;
    case SRT_CMPL:
      {
        Set::SetView sv(s);
        
        IntSetRanges dr1(is);
        Set::RangesCompl<IntSetRanges> dc1(dr1);
        IntSet dcompl(dc1);
        Set::ConstantView cvcompl(home, dcompl);
        
        GECODE_ES_FAIL(home,
                       (Set::Rel::ReEq<Set::SetView,Set::ConstantView>
                        ::post(home, sv, cvcompl, b)));
      }
      break;
    }
  }

}

// STATISTICS: set-post
