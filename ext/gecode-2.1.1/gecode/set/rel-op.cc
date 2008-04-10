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
 *     $Date: 2008-02-01 11:29:52 +0100 (Fri, 01 Feb 2008) $ by $Author: tack $
 *     $Revision: 6032 $
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

#include "gecode/set/rel-op.hh"

namespace Gecode {
  using namespace Gecode::Set;
  using namespace Gecode::Set::Rel;
  using namespace Gecode::Set::RelOp;

  void
  rel(Space* home, SetVar x, SetOpType op, SetVar y, SetRelType r, SetVar z) {
    rel_op_post<SetView,SetView,SetView>(home, x, op, y, r, z);
  }

  void
  rel(Space* home, SetOpType op, const SetVarArgs& x, SetVar y) {
    if (home->failed()) return;
    ViewArray<SetView> xa(home,x);
    switch(op) {
    case SOT_UNION:
      GECODE_ES_FAIL(home,(RelOp::UnionN<SetView,SetView>::post(home, xa, y)));
      break;
    case SOT_DUNION:
      GECODE_ES_FAIL(home,
                     (RelOp::PartitionN<SetView,SetView>::post(home, xa, y)));
      break;
    case SOT_INTER:
      {
        GECODE_ES_FAIL(home,
                       (RelOp::IntersectionN<SetView,SetView>
                        ::post(home, xa, y)));
      }
      break;
    case SOT_MINUS:
      throw InvalidRelation("rel minus");
      break;
    }
  }

  void
  rel(Space* home, SetOpType op, const SetVarArgs& x, const IntSet& z, SetVar y) {
    if (home->failed()) return;
    Set::Limits::check(z, "Set::rel");
    ViewArray<SetView> xa(home,x);
    switch(op) {
    case SOT_UNION:
      GECODE_ES_FAIL(home,(RelOp::UnionN<SetView,SetView>::post(home, xa, z, y)));
      break;
    case SOT_DUNION:
      GECODE_ES_FAIL(home,
                     (RelOp::PartitionN<SetView,SetView>::post(home, xa, z, y)));
      break;
    case SOT_INTER:
      {
        GECODE_ES_FAIL(home,
                       (RelOp::IntersectionN<SetView,SetView>
                        ::post(home, xa, z, y)));
      }
      break;
    case SOT_MINUS:
      throw InvalidRelation("rel minus");
      break;
    }
  }

  void
  rel(Space* home, SetOpType op, const IntVarArgs& x, SetVar y) {
    if (home->failed()) return;
    ViewArray<SingletonView> xa(home,x.size());
    for (int i=x.size(); i--;) {
      Int::IntView iv(x[i]);
      SingletonView sv(iv);
      xa[i] = sv;
    }
      
    switch(op) {
    case SOT_UNION:
      GECODE_ES_FAIL(home,(RelOp::UnionN<SingletonView,SetView>
                           ::post(home, xa, y)));
      break;
    case SOT_DUNION:
      GECODE_ES_FAIL(home,(RelOp::PartitionN<SingletonView,SetView>
                           ::post(home, xa, y)));
      break;
    case SOT_INTER:
      GECODE_ES_FAIL(home,
                     (RelOp::IntersectionN<SingletonView,SetView>
                      ::post(home, xa, y)));
      break;
    case SOT_MINUS:
      throw InvalidRelation("rel minus");
      break;
    }
  }

  void
  rel(Space* home, SetOpType op, const IntVarArgs& x, const IntSet& z, SetVar y) {
    if (home->failed()) return;
    Set::Limits::check(z, "Set::rel");
    ViewArray<SingletonView> xa(home,x.size());
    for (int i=x.size(); i--;) {
      Int::IntView iv(x[i]);
      SingletonView sv(iv);
      xa[i] = sv;
    }
      
    switch(op) {
    case SOT_UNION:
      GECODE_ES_FAIL(home,(RelOp::UnionN<SingletonView,SetView>
                           ::post(home, xa, z, y)));
      break;
    case SOT_DUNION:
      GECODE_ES_FAIL(home,(RelOp::PartitionN<SingletonView,SetView>
                           ::post(home, xa, z, y)));
      break;
    case SOT_INTER:
      GECODE_ES_FAIL(home,
                     (RelOp::IntersectionN<SingletonView,SetView>
                      ::post(home, xa, z, y)));
      break;
    case SOT_MINUS:
      throw InvalidRelation("rel minus");
      break;
    }
  }

  namespace {

    GECODE_REGISTER3(RelOp::Union<SingletonView, SingletonView, SetView>);
    GECODE_REGISTER3(RelOp::Union<SetView, SetView, ComplementView<SetView> >);
    GECODE_REGISTER3(RelOp::Union<SetView, SetView, SetView>);

    GECODE_REGISTER2(Set::RelOp::UnionN<SetView,SetView>);
    GECODE_REGISTER2(Set::RelOp::UnionN<SingletonView,SetView>);

    GECODE_REGISTER3(RelOp::Intersection<SingletonView, SingletonView, SetView>);
    GECODE_REGISTER3(RelOp::Intersection<SetView, ComplementView<SetView>, SetView>);
    GECODE_REGISTER3(RelOp::Intersection<SetView, ComplementView<SetView>, ComplementView<SetView> >);
    GECODE_REGISTER3(RelOp::Intersection<SetView, SetView, ComplementView<SetView> >);
    GECODE_REGISTER3(RelOp::Intersection<SetView, SetView, SetView>);

    GECODE_REGISTER2(Set::RelOp::IntersectionN<SetView,SetView>);
    GECODE_REGISTER2(Set::RelOp::IntersectionN<SingletonView,SetView>);

    GECODE_REGISTER2(Set::RelOp::PartitionN<SetView,SetView>);
    GECODE_REGISTER2(Set::RelOp::PartitionN<SingletonView,SetView>);

    GECODE_REGISTER3(RelOp::SubOfUnion<SetView, SetView, SetView>);

    GECODE_REGISTER3(RelOp::SuperOfInter<SetView, SingletonView, EmptyView>);
    GECODE_REGISTER3(RelOp::SuperOfInter<SetView, ComplementView<SetView>, SetView>);
    GECODE_REGISTER3(RelOp::SuperOfInter<SetView, SetView, EmptyView>);
    GECODE_REGISTER3(RelOp::SuperOfInter<SetView, SetView, SetView>);

  }

}

// STATISTICS: set-post
