/* -*- mode: C++; c-basic-offset: 2; indent-tabs-mode: nil -*- */
/*
 *  Main authors:
 *     Christian Schulte <schulte@gecode.org>
 *
 *  Copyright:
 *     Christian Schulte, 2002
 *
 *  Last modified:
 *     $Date: 2007-11-01 22:21:38 +0100 (Thu, 01 Nov 2007) $ by $Author: schulte $
 *     $Revision: 5184 $
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

#include "gecode/int/bool.hh"
#include "gecode/int/rel.hh"

namespace Gecode {

  namespace {

    forceinline void
    post_and(Space* home, BoolVar x0, BoolVar x1, BoolVar x2) {
      using namespace Int;
      NegBoolView n0(x0); NegBoolView n1(x1); NegBoolView n2(x2);
      GECODE_ES_FAIL(home,(Bool::Or<NegBoolView,NegBoolView,NegBoolView>
                           ::post(home,n0,n1,n2)));
    }
    forceinline void
    post_or(Space* home, BoolVar x0, BoolVar x1, BoolVar x2) {
      using namespace Int;
      GECODE_ES_FAIL(home,(Bool::Or<BoolView,BoolView,BoolView>
                           ::post(home,x0,x1,x2)));
    }
    forceinline void
    post_imp(Space* home, BoolVar x0, BoolVar x1, BoolVar x2) {
      using namespace Int;
      NegBoolView n0(x0);
      GECODE_ES_FAIL(home,(Bool::Or<NegBoolView,BoolView,BoolView>
                           ::post(home,n0,x1,x2)));
    }
    forceinline void
    post_eqv(Space* home, BoolVar x0, BoolVar x1, BoolVar x2) {
      using namespace Int;
      GECODE_ES_FAIL(home,(Bool::Eqv<BoolView,BoolView,BoolView>
                           ::post(home,x0,x1,x2)));
    }
    forceinline void
    post_xor(Space* home, BoolVar x0, BoolVar x1, BoolVar x2) {
      using namespace Int;
      NegBoolView n2(x2);
      GECODE_ES_FAIL(home,(Bool::Eqv<BoolView,BoolView,NegBoolView>
                           ::post(home,x0,x1,n2)));
    }

  }

  void
  rel(Space* home, BoolVar x0, IntRelType r, BoolVar x1, 
      IntConLevel, PropKind) {
    using namespace Int;
    if (home->failed()) return;
    switch (r) {
    case IRT_EQ:
      GECODE_ES_FAIL(home,(Bool::Eq<BoolView,BoolView>
                           ::post(home,x0,x1)));
      break;
    case IRT_NQ: 
      {
        NegBoolView n1(x1);
        GECODE_ES_FAIL(home,(Bool::Eq<BoolView,NegBoolView>
                             ::post(home,x0,n1)));
      }
      break;
    case IRT_GQ:
      GECODE_ES_FAIL(home,Bool::Lq<BoolView>::post(home,x1,x0)); 
      break;
    case IRT_LQ:
      GECODE_ES_FAIL(home,Bool::Lq<BoolView>::post(home,x0,x1)); 
      break;
    case IRT_GR:
      GECODE_ES_FAIL(home,Bool::Le<BoolView>::post(home,x1,x0)); 
      break;
    case IRT_LE:
      GECODE_ES_FAIL(home,Bool::Le<BoolView>::post(home,x0,x1)); 
      break;
    default:
      throw UnknownRelation("Int::rel");
    }
  }

  void
  rel(Space* home, const BoolVarArgs& x, IntRelType r, BoolVar y, 
      IntConLevel, PropKind) {
    using namespace Int;
    if (home->failed()) return;
    switch (r) {
    case IRT_EQ:
      for (int i=x.size(); i--; ) {
        GECODE_ES_FAIL(home,(Bool::Eq<BoolView,BoolView>
                             ::post(home,x[i],y)));
      }
      break;
    case IRT_NQ: 
      {
        NegBoolView n(y);
        for (int i=x.size(); i--; ) {
          GECODE_ES_FAIL(home,(Bool::Eq<BoolView,NegBoolView>
                               ::post(home,x[i],n)));
        }
      }
      break;
    case IRT_GQ:
      for (int i=x.size(); i--; ) {
        GECODE_ES_FAIL(home,Bool::Lq<BoolView>::post(home,y,x[i])); 
      }
      break;
    case IRT_LQ:
      for (int i=x.size(); i--; ) {
        GECODE_ES_FAIL(home,Bool::Lq<BoolView>::post(home,x[i],y)); 
      }
      break;
    case IRT_GR:
      for (int i=x.size(); i--; ) {
        GECODE_ES_FAIL(home,Bool::Le<BoolView>::post(home,y,x[i])); 
      }
      break;
    case IRT_LE:
      for (int i=x.size(); i--; ) {
        GECODE_ES_FAIL(home,Bool::Le<BoolView>::post(home,x[i],y)); 
      }
      break;
    default:
      throw UnknownRelation("Int::rel");
    }
  }

  void
  rel(Space* home, BoolVar x0, IntRelType r, int n, IntConLevel, PropKind) {
    using namespace Int;
    if (home->failed()) return;
    BoolView x(x0);
    if (n == 0) {
      switch (r) {
      case IRT_LQ:
      case IRT_EQ:
        GECODE_ME_FAIL(home,x.zero(home)); break;
      case IRT_NQ:
      case IRT_GR:
        GECODE_ME_FAIL(home,x.one(home)); break;
      case IRT_LE:
        home->fail(); break;
      case IRT_GQ:
        break;
      default:
        throw UnknownRelation("Int::rel");
      }
    } else if (n == 1) {
      switch (r) {
      case IRT_GQ:
      case IRT_EQ:
        GECODE_ME_FAIL(home,x.one(home)); break;
      case IRT_NQ:
      case IRT_LE:
        GECODE_ME_FAIL(home,x.zero(home)); break;
      case IRT_GR:
        home->fail(); break;
      case IRT_LQ:
        break;
      default:
        throw UnknownRelation("Int::rel");
      }
    } else {
      throw NotZeroOne("Int::rel");
    }
  }

  void
  rel(Space* home, const BoolVarArgs& x, IntRelType r, int n, 
      IntConLevel, PropKind) {
    using namespace Int;
    if (home->failed()) return;
    if (n == 0) {
      switch (r) {
      case IRT_LQ:
      case IRT_EQ:
        for (int i=x.size(); i--; ) {
          BoolView xi(x[i]); GECODE_ME_FAIL(home,xi.zero(home)); 
        }
        break;
      case IRT_NQ:
      case IRT_GR:
        for (int i=x.size(); i--; ) {
          BoolView xi(x[i]); GECODE_ME_FAIL(home,xi.one(home)); 
        }
        break;
      case IRT_LE:
        home->fail(); break;
      case IRT_GQ:
        break;
      default:
        throw UnknownRelation("Int::rel");
      }
    } else if (n == 1) {
      switch (r) {
      case IRT_GQ:
      case IRT_EQ:
        for (int i=x.size(); i--; ) {
          BoolView xi(x[i]); GECODE_ME_FAIL(home,xi.one(home)); 
        }
        break;
      case IRT_NQ:
      case IRT_LE:
        for (int i=x.size(); i--; ) {
          BoolView xi(x[i]); GECODE_ME_FAIL(home,xi.zero(home)); 
        }
        break;
      case IRT_GR:
        home->fail(); break;
      case IRT_LQ:
        break;
      default:
        throw UnknownRelation("Int::rel");
      }
    } else {
      throw NotZeroOne("Int::rel");
    }
  }

  void
  rel(Space* home, const BoolVarArgs& x, IntRelType r, IntConLevel, PropKind) {
    using namespace Int;
    if (home->failed() || (x.size() < 2)) return;
    switch (r) {
    case IRT_EQ:
      for (int i=x.size()-1; i--; )
        GECODE_ES_FAIL(home,(Bool::Eq<BoolView,BoolView>
                             ::post(home,x[i],x[i+1])));
      break;
    case IRT_NQ:
      if (x.size() == 2) {
        NegBoolView n(x[1]);
        GECODE_ES_FAIL(home,(Bool::Eq<BoolView,NegBoolView>
                             ::post(home,x[0],n)));
      } else {
        home->fail();
      }
      break;
    case IRT_LE:
      if (x.size() == 2) {
        GECODE_ES_FAIL(home,Bool::Le<BoolView>::post(home,x[0],x[1]));
      } else {
        home->fail();
      }
      break;
    case IRT_LQ:
      for (int i=x.size()-1; i--; )
        GECODE_ES_FAIL(home,Bool::Lq<BoolView>::post(home,x[i],x[i+1]));
      break;
    case IRT_GR:
      if (x.size() == 2) {
        GECODE_ES_FAIL(home,Bool::Le<BoolView>::post(home,x[1],x[0]));
      } else {
        home->fail();
      }
      break;
    case IRT_GQ:
      for (int i=x.size()-1; i--; )
        GECODE_ES_FAIL(home,Bool::Lq<BoolView>::post(home,x[i+1],x[i]));
      break;
    default:
      throw UnknownRelation("Int::rel");
    }
  }

  void
  rel(Space* home, const BoolVarArgs& x, IntRelType r, const BoolVarArgs& y,
      IntConLevel, PropKind) {
    using namespace Int;
    if (x.size() != y.size())
      throw ArgumentSizeMismatch("Int::rel");
    if (home->failed()) return;

    switch (r) {
    case IRT_GR: 
      {
        ViewArray<ViewTuple<BoolView,2> > xy(home,x.size());
        for (int i = x.size(); i--; ) {
          xy[i][0]=y[i]; xy[i][1]=x[i];
        }
        GECODE_ES_FAIL(home,Rel::Lex<BoolView>::post(home,xy,true));
      }
      break;
    case IRT_LE: 
      {
        ViewArray<ViewTuple<BoolView,2> > xy(home,x.size());
        for (int i = x.size(); i--; ) {
          xy[i][0]=x[i]; xy[i][1]=y[i];
        }
        GECODE_ES_FAIL(home,Rel::Lex<BoolView>::post(home,xy,true));
      }
      break;
    case IRT_GQ: 
      {
        ViewArray<ViewTuple<BoolView,2> > xy(home,x.size());
        for (int i = x.size(); i--; ) {
          xy[i][0]=y[i]; xy[i][1]=x[i];
        }
        GECODE_ES_FAIL(home,Rel::Lex<BoolView>::post(home,xy,false));
      }
      break;
    case IRT_LQ: 
      {
        ViewArray<ViewTuple<BoolView,2> > xy(home,x.size());
        for (int i = x.size(); i--; ) {
          xy[i][0]=x[i]; xy[i][1]=y[i];
        }
        GECODE_ES_FAIL(home,Rel::Lex<BoolView>::post(home,xy,false));
      }
      break;
    case IRT_EQ:
      for (int i=x.size(); i--; ) {
        GECODE_ES_FAIL(home,(Bool::Eq<BoolView,BoolView>
                             ::post(home,x[i],y[i])));
      }
      break;
    case IRT_NQ: 
      {
        ViewArray<ViewTuple<BoolView,2> > xy(home,x.size());
        for (int i = x.size(); i--; ) {
          xy[i][0]=x[i]; xy[i][1]=y[i];
        }
        GECODE_ES_FAIL(home,Rel::NaryNq<BoolView>::post(home,xy));
      }
      break;
    default:
      throw UnknownRelation("Int::rel");
    }
  }

  void
  rel(Space* home, BoolVar x0, BoolOpType o, BoolVar x1, BoolVar x2, 
      IntConLevel, PropKind) {
    using namespace Int;
    if (home->failed()) return;
    switch (o) {
    case BOT_AND: post_and(home,x0,x1,x2); break;
    case BOT_OR:  post_or(home,x0,x1,x2); break;
    case BOT_IMP: post_imp(home,x0,x1,x2); break;
    case BOT_EQV: post_eqv(home,x0,x1,x2); break;
    case BOT_XOR: post_xor(home,x0,x1,x2); break;
    default: throw UnknownBoolOp("Int::rel");
    }
  }

  void
  rel(Space* home, BoolVar x0, BoolOpType o, BoolVar x1, int n, 
      IntConLevel, PropKind) {
    using namespace Int;
    if (home->failed()) return;
    if (n == 0) {
      switch (o) {
      case BOT_AND:
        {
          NegBoolView n0(x0); NegBoolView n1(x1);
          GECODE_ES_FAIL(home,(Bool::BinOrTrue<NegBoolView,NegBoolView>
                               ::post(home,n0,n1)));
        }
        break;
      case BOT_OR:
        {
          BoolView b0(x0); BoolView b1(x1);
          GECODE_ME_FAIL(home,b0.zero(home));
          GECODE_ME_FAIL(home,b1.zero(home));
        }
        break;
      case BOT_IMP:
        {
          BoolView b0(x0); BoolView b1(x1);
          GECODE_ME_FAIL(home,b0.one(home));
          GECODE_ME_FAIL(home,b1.zero(home));
        }
        break;
      case BOT_EQV:
        {
          NegBoolView n0(x0);
          GECODE_ES_FAIL(home,(Bool::Eq<NegBoolView,BoolView>
                               ::post(home,n0,x1)));
        }
        break;
      case BOT_XOR:
        GECODE_ES_FAIL(home,(Bool::Eq<BoolView,BoolView>
                             ::post(home,x0,x1)));
        break;
      default:
        throw UnknownBoolOp("Int::rel");
      }
    } else if (n == 1) {
      switch (o) {
      case BOT_AND:
        {
          BoolView b0(x0); BoolView b1(x1);
          GECODE_ME_FAIL(home,b0.one(home));
          GECODE_ME_FAIL(home,b1.one(home));
        }
        break;
      case BOT_OR:
        GECODE_ES_FAIL(home,(Bool::BinOrTrue<BoolView,BoolView>
                             ::post(home,x0,x1)));
        break;
      case BOT_IMP:
        {
          NegBoolView n0(x0);
          GECODE_ES_FAIL(home,(Bool::BinOrTrue<NegBoolView,BoolView>
                               ::post(home,n0,x1)));
        }
        break;
      case BOT_EQV:
        GECODE_ES_FAIL(home,(Bool::Eq<BoolView,BoolView>
                             ::post(home,x0,x1)));
        break;
      case BOT_XOR:
        {
          NegBoolView n0(x0);
          GECODE_ES_FAIL(home,(Bool::Eq<NegBoolView,BoolView>
                               ::post(home,n0,x1)));
        }
        break;
      default:
        throw UnknownBoolOp("Int::rel");
      }
    } else {
      throw NotZeroOne("Int::rel");
    }
  }

  void
  rel(Space* home, BoolOpType o, const BoolVarArgs& x, BoolVar y, 
      IntConLevel, PropKind) {
    using namespace Int;
    if (home->failed()) return;
    int m = x.size();
    switch (o) {
    case BOT_AND:
      {
        ViewArray<NegBoolView> b(home,m);
        for (int i=m; i--; ) {
          NegBoolView nb(x[i]); b[i]=nb;
        }
        NegBoolView ny(y);
        b.unique();
        GECODE_ES_FAIL(home,Bool::NaryOr<NegBoolView>::post(home,b,ny));
      }
      break;
    case BOT_OR:
      {
        ViewArray<BoolView> b(home,x);
        b.unique();
        GECODE_ES_FAIL(home,Bool::NaryOr<BoolView>::post(home,b,y));
      }
      break;
    case BOT_IMP:
      if (m < 2) {
        throw TooFewArguments("Int::rel");
      } else {
        GECODE_AUTOARRAY(BoolVar,z,m);
        z[0]=x[0]; z[m-1]=y;
        for (int i=1; i<m-1; i++)
          z[i].init(home,0,1);
        for (int i=1; i<m; i++)
          post_imp(home,z[i-1],x[i],z[i]);
      }
      break;
    case BOT_EQV:
      if (m < 2) {
        throw TooFewArguments("Int::rel");
      } else {
        GECODE_AUTOARRAY(BoolVar,z,m);
        z[0]=x[0]; z[m-1]=y;
        for (int i=1; i<m-1; i++)
          z[i].init(home,0,1);
        for (int i=1; i<m; i++)
          post_eqv(home,z[i-1],x[i],z[i]);
      }
      break;
    case BOT_XOR:
      if (m < 2) {
        throw TooFewArguments("Int::rel");
      } else {
        GECODE_AUTOARRAY(BoolVar,z,m);
        z[0]=x[0]; z[m-1]=y;
        for (int i=1; i<m-1; i++)
          z[i].init(home,0,1);
        for (int i=1; i<m; i++)
          post_xor(home,z[i-1],x[i],z[i]);
      }
      break;
    default:
      throw UnknownBoolOp("Int::rel");
    }
  }

  void
  rel(Space* home, BoolOpType o, const BoolVarArgs& x, int n, 
      IntConLevel, PropKind) {
    using namespace Int;
    if ((n < 0) || (n > 1))
      throw NotZeroOne("Int::rel");
    if (home->failed()) return;
    int m = x.size();
    switch (o) {
    case BOT_AND:
      if (n == 0) {
        ViewArray<NegBoolView> b(home,m);
        for (int i=m; i--; ) {
          NegBoolView nb(x[i]); b[i]=nb;
        }
        b.unique();
        GECODE_ES_FAIL(home,Bool::NaryOrTrue<NegBoolView>::post(home,b));
      } else {
        for (int i=m; i--; ) {
          BoolView b(x[i]); GECODE_ME_FAIL(home,b.one(home));
        }
      }
      break;
    case BOT_OR:
      if (n == 0) {
        for (int i=m; i--; ) {
          BoolView b(x[i]); GECODE_ME_FAIL(home,b.zero(home));
        }
      } else {
        ViewArray<BoolView> b(home,x);
        b.unique();
        GECODE_ES_FAIL(home,Bool::NaryOrTrue<BoolView>::post(home,b));
      }
      break;
    case BOT_IMP:
      if (m < 2) {
        throw TooFewArguments("Int::rel");
      } else {
        GECODE_AUTOARRAY(BoolVar,z,m);
        z[0]=x[0]; z[m-1].init(home,n,n);;
        for (int i=1; i<m-1; i++)
          z[i].init(home,0,1);
        for (int i=1; i<m; i++)
          post_imp(home,z[i-1],x[i],z[i]);
      }
      break;
    case BOT_EQV:
      if (m < 2) {
        throw TooFewArguments("Int::rel");
      } else {
        GECODE_AUTOARRAY(BoolVar,z,m);
        z[0]=x[0]; z[m-1].init(home,n,n);
        for (int i=1; i<m-1; i++)
          z[i].init(home,0,1);
        for (int i=1; i<m; i++)
          post_eqv(home,z[i-1],x[i],z[i]);
      }
      break;
    case BOT_XOR:
      if (m < 2) {
        throw TooFewArguments("Int::rel");
      } else {
        GECODE_AUTOARRAY(BoolVar,z,m);
        z[0]=x[0]; z[m-1].init(home,n,n);
        for (int i=1; i<m-1; i++)
          z[i].init(home,0,1);
        for (int i=1; i<m; i++)
          post_xor(home,z[i-1],x[i],z[i]);
      }
      break;
    default:
      throw UnknownBoolOp("Int::rel");
    }
  }

  namespace {
    using namespace Int;
    GECODE_REGISTER2(Bool::BinOrTrue<NegBoolView, BoolView>);
    GECODE_REGISTER2(Bool::BinOrTrue<NegBoolView, NegBoolView>);
    GECODE_REGISTER2(Bool::BinOrTrue<BoolView, BoolView>);
    
    GECODE_REGISTER2(Bool::Eq<NegBoolView, BoolView>);
    GECODE_REGISTER2(Bool::Eq<NegBoolView, NegBoolView>);
    GECODE_REGISTER2(Bool::Eq<BoolView, NegBoolView>);
    GECODE_REGISTER2(Bool::Eq<BoolView, BoolView>);
    GECODE_REGISTER1(Bool::NaryEq<BoolView>);
    
    GECODE_REGISTER3(Bool::Eqv<BoolView, BoolView, NegBoolView>);
    GECODE_REGISTER3(Bool::Eqv<BoolView, BoolView, BoolView>);
    
    GECODE_REGISTER1(Bool::Lq<BoolView>);
    
    GECODE_REGISTER1(Bool::NaryOr<NegBoolView>);
    GECODE_REGISTER1(Bool::NaryOr<BoolView>);
    
    GECODE_REGISTER1(Bool::NaryOrTrue<NegBoolView>);
    GECODE_REGISTER1(Bool::NaryOrTrue<BoolView>);
    
    GECODE_REGISTER3(Bool::Or<NegBoolView, BoolView, BoolView>);
    GECODE_REGISTER3(Bool::Or<NegBoolView, NegBoolView, NegBoolView>);
    GECODE_REGISTER3(Bool::Or<BoolView, BoolView, BoolView>);
    
    GECODE_REGISTER1(Bool::OrTrueSubsumed<NegBoolView>);
    GECODE_REGISTER1(Bool::OrTrueSubsumed<BoolView>);
    
    GECODE_REGISTER1(Bool::QuadOrTrue<NegBoolView>);
    GECODE_REGISTER1(Bool::QuadOrTrue<BoolView>);
    
    GECODE_REGISTER1(Bool::TerOrTrue<NegBoolView>);
    GECODE_REGISTER1(Bool::TerOrTrue<BoolView>);
  }

}


// STATISTICS: int-post

