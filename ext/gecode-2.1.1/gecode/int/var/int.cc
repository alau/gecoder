/* -*- mode: C++; c-basic-offset: 2; indent-tabs-mode: nil -*- */
/*
 *  Main authors:
 *     Christian Schulte <schulte@gecode.org>
 *
 *  Copyright:
 *     Christian Schulte, 2002
 *
 *  Last modified:
 *     $Date: 2008-02-22 06:55:38 +0100 (Fri, 22 Feb 2008) $ by $Author: schulte $
 *     $Revision: 6274 $
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

#include "gecode/int.hh"

namespace Gecode {

  IntVar::IntVar(Space* home, int min, int max)
    : VarBase<Int::IntVarImp>(new (home) Int::IntVarImp(home,min,max)) {
    Int::Limits::check(min,"IntVar::IntVar");
    Int::Limits::check(max,"IntVar::IntVar");
    if (min > max)
      throw Int::VariableEmptyDomain("IntVar::IntVar");
  }

  IntVar::IntVar(Space* home, const IntSet& ds)
    : VarBase<Int::IntVarImp>(new (home) Int::IntVarImp(home,ds)) {
    Int::Limits::check(ds.min(),"IntVar::IntVar");
    Int::Limits::check(ds.max(),"IntVar::IntVar");
    if (ds.size() == 0)
      throw Int::VariableEmptyDomain("IntVar::IntVar");
  }

  void
  IntVar::init(Space* home, int min, int max) {
    Int::Limits::check(min,"IntVar::IntVar");
    Int::Limits::check(max,"IntVar::IntVar");
    if (min > max)
      throw Int::VariableEmptyDomain("IntVar::init");
    varimp = new (home) Int::IntVarImp(home,min,max);
  }

  void
  IntVar::init(Space* home, const IntSet& ds) {
    Int::Limits::check(ds.min(),"IntVar::IntVar");
    Int::Limits::check(ds.max(),"IntVar::IntVar");
    if (ds.size() == 0)
      throw Int::VariableEmptyDomain("IntVar::init");
    varimp = new (home) Int::IntVarImp(home,ds);
  }
  
}

// STATISTICS: int-var

