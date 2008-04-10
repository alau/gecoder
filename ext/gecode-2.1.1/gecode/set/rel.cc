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
 *     $Date: 2008-02-19 16:09:54 +0100 (Tue, 19 Feb 2008) $ by $Author: tack $
 *     $Revision: 6236 $
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

#include "gecode/set/rel.hh"
#include "gecode/set/rel-op.hh"
#include "gecode/set/int.hh"

namespace Gecode {
  using namespace Set;
  using namespace Set::Rel;
  using namespace Set::RelOp;
  
  template <class View0, class View1>
  void
  rel_post(Space* home, View0 x0, SetRelType r, View1 x1) {
    if (home->failed()) return;
    switch(r) {
    case SRT_EQ:
      {
        GECODE_ES_FAIL(home,
                       (Eq<View0,View1>::post(home,x0,x1)));
      }
      break;
    case SRT_NQ:
      {
        GECODE_ES_FAIL(home,
                       (Distinct<View0,View1>::post(home,x0,x1)));
      }
      break;
    case SRT_SUB:
      {
        GECODE_ES_FAIL(home,
                       (SubSet<View0,View1>::post(home, x0,x1)));
      }
      break;
    case SRT_SUP:
      {
        GECODE_ES_FAIL(home,
                       (SubSet<View1,View0>::post(home, x1,x0)));
      }
      break;
    case SRT_DISJ:
      {
        EmptyView emptyset;
        GECODE_ES_FAIL(home,(SuperOfInter<View0,View1,EmptyView>
                             ::post(home, x0, x1, emptyset)));
      }
      break;
    case SRT_CMPL:
      {
        ComplementView<View0> cx0(x0);
        GECODE_ES_FAIL(home,
                       (Eq<ComplementView<View0>, View1>
                        ::post(home, cx0, x1)));
      }
      break;
    }
  }

  template <class View0, class View1>
  void
  rel_re(Space* home, View0 x, SetRelType r, View1 y, BoolVar b) {
    if (home->failed()) return;
    switch(r) {
    case SRT_EQ:
      {
        GECODE_ES_FAIL(home,
                       (ReEq<View0,View1>::post(home, x,y,b)));
      }
      break;
    case SRT_NQ:
      {
        BoolVar notb(home, 0, 1);
        rel(home, b, IRT_NQ, notb);
        GECODE_ES_FAIL(home,
                       (ReEq<View0,View1>::post(home,x,y,notb)));
      }
      break;
    case SRT_SUB:
      {
        GECODE_ES_FAIL(home,
                       (ReSubset<View0,View1>::post(home, x,y,b)));
      }
      break;
    case SRT_SUP:
      {
        GECODE_ES_FAIL(home,
                       (ReSubset<View1,View0>::post(home, y,x,b)));
      }
      break;
    case SRT_DISJ:
      {
        // x||y <=> b is equivalent to
        // ( y <= complement(x) ) <=> b

        ComplementView<View0> xc(x);
        GECODE_ES_FAIL(home,
                       (ReSubset<View1,ComplementView<View0> >
                        ::post(home, y, xc, b)));
      }
      break;
    case SRT_CMPL:
      {
        ComplementView<View0> xc(x);
        GECODE_ES_FAIL(home,
                       (ReEq<ComplementView<View0>,View1>
                       ::post(home, xc, y, b)));
      }
      break;
    }
  }

  void
  rel(Space* home, SetVar x, SetRelType r, SetVar y) {
    rel_post<SetView,SetView>(home,x,r,y);
  }

  void
  rel(Space* home, SetVar s, SetRelType r, IntVar x) {
    Gecode::Int::IntView xv(x);
    SingletonView xsingle(xv);
    rel_post<SetView,SingletonView>(home,s,r,xv);
  }

  void
  rel(Space* home, IntVar x, SetRelType r, SetVar s) {
    switch(r) {
    case SRT_SUB:
      rel(home, s, SRT_SUP, x);
      break;
    case SRT_SUP:
      rel(home, s, SRT_SUB, x);
      break;
    default:
      rel(home, s, r, x);
    }
  }

  void
  rel(Space* home, SetVar x, SetRelType r, SetVar y, BoolVar b) {
    rel_re<SetView,SetView>(home,x,r,y,b);
  }

  void
  rel(Space* home, SetVar s, SetRelType r, IntVar x, BoolVar b) {
    Gecode::Int::IntView xv(x);
    SingletonView xsingle(xv);
    rel_re<SetView,SingletonView>(home,s,r,xsingle,b);
  }

  void
  rel(Space* home, IntVar x, SetRelType r, SetVar s, BoolVar b) {
    switch(r) {
    case SRT_SUB:
      rel(home, s, SRT_SUP, x, b);
      break;
    case SRT_SUP:
      rel(home, s, SRT_SUB, x, b);
      break;
    default:
      rel(home, s, r, x, b);
    }
  }  

  namespace {
    GECODE_REGISTER1(Rel::DistinctDoit<ConstantView>);
    GECODE_REGISTER1(Rel::DistinctDoit<SingletonView>);
    GECODE_REGISTER1(Rel::DistinctDoit<ComplementView<SetView> >);
    GECODE_REGISTER1(Rel::DistinctDoit<SetView>);
    GECODE_REGISTER2(Rel::Eq<ConstantView, ComplementView<SetView> >);
    GECODE_REGISTER2(Rel::Eq<ConstantView, SetView>);
    GECODE_REGISTER2(Rel::Eq<ConstantView, ConstantView>);
    GECODE_REGISTER2(Rel::Eq<SingletonView, SetView>);
    GECODE_REGISTER2(Rel::Eq<ComplementView<SetView>, ConstantView>);
    GECODE_REGISTER2(Rel::Eq<ComplementView<SetView>, SingletonView>);
    GECODE_REGISTER2(Rel::Eq<ComplementView<SetView>, SetView>);
    GECODE_REGISTER2(Rel::Eq<SetView, ConstantView>);
    GECODE_REGISTER2(Rel::Eq<SetView, SingletonView>);
    GECODE_REGISTER2(Rel::Eq<SetView, ComplementView<SetView> >);
    GECODE_REGISTER2(Rel::Eq<SetView, SetView>);
    GECODE_REGISTER2(Rel::ReEq<ComplementView<SetView>, ConstantView>);
    GECODE_REGISTER2(Rel::ReEq<ComplementView<SetView>, SingletonView>);
    GECODE_REGISTER2(Rel::ReEq<ComplementView<SetView>, SetView>);
    GECODE_REGISTER2(Rel::ReEq<SetView, ConstantView>);
    GECODE_REGISTER2(Rel::ReEq<SetView, SingletonView>);
    GECODE_REGISTER2(Rel::ReEq<SetView, SetView>);
    GECODE_REGISTER2(Rel::SubSet<ConstantView, SetView>);
    GECODE_REGISTER2(Rel::SubSet<SingletonView, SetView>);
    GECODE_REGISTER2(Rel::SubSet<ComplementView<SetView>, ConstantView>);
    GECODE_REGISTER2(Rel::SubSet<ComplementView<SetView>, SingletonView>);
    GECODE_REGISTER2(Rel::SubSet<ComplementView<SetView>, SetView>);
    GECODE_REGISTER2(Rel::SubSet<SetView, ConstantView>);
    GECODE_REGISTER2(Rel::SubSet<SetView, SingletonView>);
    GECODE_REGISTER2(Rel::SubSet<SetView, SetView>);
    GECODE_REGISTER2(Rel::Distinct<ComplementView<SetView>, ConstantView>);
    GECODE_REGISTER2(Rel::Distinct<ComplementView<SetView>, SingletonView>);
    GECODE_REGISTER2(Rel::Distinct<ComplementView<SetView>, SetView>);
    GECODE_REGISTER2(Rel::Distinct<SetView, ConstantView>);
    GECODE_REGISTER2(Rel::Distinct<SetView, SingletonView>);
    GECODE_REGISTER2(Rel::Distinct<SetView, SetView>);
    GECODE_REGISTER2(Rel::NoSubSet<ConstantView, SetView>);
    GECODE_REGISTER2(Rel::NoSubSet<SingletonView, SetView>);
    GECODE_REGISTER2(Rel::NoSubSet<ComplementView<SetView>, ConstantView>);
    GECODE_REGISTER2(Rel::NoSubSet<ComplementView<SetView>, SingletonView>);
    GECODE_REGISTER2(Rel::NoSubSet<ComplementView<SetView>, SetView>);
    GECODE_REGISTER2(Rel::NoSubSet<SetView, ConstantView>);
    GECODE_REGISTER2(Rel::NoSubSet<SetView, SingletonView>);
    GECODE_REGISTER2(Rel::NoSubSet<SetView, SetView>);
    GECODE_REGISTER2(Rel::ReSubset<ConstantView, SetView>);
    GECODE_REGISTER2(Rel::ReSubset<SingletonView, SetView>);
    GECODE_REGISTER2(Rel::ReSubset<ConstantView, ComplementView<SetView> >);
    GECODE_REGISTER2(Rel::ReSubset<SingletonView, ComplementView<SetView> >);
    GECODE_REGISTER2(Rel::ReSubset<SetView, ComplementView<SetView> >);
    GECODE_REGISTER2(Rel::ReSubset<SetView, ConstantView>);
    GECODE_REGISTER2(Rel::ReSubset<SetView, SingletonView>);
    GECODE_REGISTER2(Rel::ReSubset<SetView, SetView>);  
  }

}

// STATISTICS: set-post
