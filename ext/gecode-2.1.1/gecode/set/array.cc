/* -*- mode: C++; c-basic-offset: 2; indent-tabs-mode: nil -*- */
/*
 *  Main authors:
 *     Guido Tack <tack@gecode.org>
 *     Christian Schulte <schulte@gecode.org>
 *     Gabor Szokoli <szokoli@gecode.org>
 *
 *  Copyright:
 *     Guido Tack, 2004
 *     Christian Schulte, 2004
 *     Gabor Szokoli, 2004
 *
 *  Last modified:
 *     $Date: 2008-02-01 15:22:09 +0100 (Fri, 01 Feb 2008) $ by $Author: tack $
 *     $Revision: 6042 $
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

namespace Gecode {

  SetVarArray::SetVarArray(Space* home, int n)
    : VarArray<SetVar>(home,n) {
    for (int i = size(); i--; )
      x[i].init(home);
  }

  SetVarArray::SetVarArray(Space* home,int n,
                           int lbMin,int lbMax,int ubMin,int ubMax,
                           unsigned int minCard,
                           unsigned int maxCard)
    : VarArray<SetVar>(home,n) {
    Set::Limits::check(lbMin,"SetVarArray::SetVarArray");
    Set::Limits::check(lbMax,"SetVarArray::SetVarArray");
    Set::Limits::check(ubMin,"SetVarArray::SetVarArray");
    Set::Limits::check(ubMax,"SetVarArray::SetVarArray");
    Set::Limits::check(maxCard,"SetVarArray::SetVarArray");
    if (minCard > maxCard)
      throw Set::VariableEmptyDomain("SetVarArray::SetVarArray");
    for (int i = size(); i--; )
      x[i].init(home,lbMin,lbMax,ubMin,ubMax,minCard,maxCard);    
  }

  SetVarArray::SetVarArray(Space* home,int n,
                           const IntSet& glb,int ubMin,int ubMax,
                           unsigned int minCard,unsigned int maxCard)
    : VarArray<SetVar>(home,n) {
    Set::Limits::check(glb,"SetVarArray::SetVarArray");
    Set::Limits::check(ubMin,"SetVarArray::SetVarArray");
    Set::Limits::check(ubMax,"SetVarArray::SetVarArray");
    Set::Limits::check(maxCard,"SetVarArray::SetVarArray");
    if (minCard > maxCard)
      throw Set::VariableEmptyDomain("SetVarArray::SetVarArray");
    for (int i = size(); i--; )
      x[i].init(home,glb,ubMin,ubMax,minCard,maxCard);
  }

  SetVarArray::SetVarArray(Space* home,int n,
                           int lbMin,int lbMax,const IntSet& lub,
                           unsigned int minCard,unsigned int maxCard)
    : VarArray<SetVar>(home,n) {
    Set::Limits::check(lbMin,"SetVarArray::SetVarArray");
    Set::Limits::check(lbMax,"SetVarArray::SetVarArray");
    Set::Limits::check(lub,"SetVarArray::SetVarArray");
    Set::Limits::check(maxCard,"SetVarArray::SetVarArray");
    if (minCard > maxCard)
      throw Set::VariableEmptyDomain("SetVarArray::SetVarArray");
    for (int i = size(); i--; )
      x[i].init(home,lbMin,lbMax,lub,minCard,maxCard);
  }

  SetVarArray::SetVarArray(Space* home,int n,
                           const IntSet& glb, const IntSet& lub,
                           unsigned int minCard, unsigned int maxCard)
    : VarArray<SetVar>(home,n) {
    Set::Limits::check(glb,"SetVarArray::SetVarArray");
    Set::Limits::check(lub,"SetVarArray::SetVarArray");
    Set::Limits::check(maxCard,"SetVarArray::SetVarArray");
    for (int i = size(); i--; )
      x[i].init(home,glb,lub,minCard,maxCard);
    if (minCard > maxCard)
      throw Set::VariableEmptyDomain("SetVar");
  }

}

// STATISTICS: set-other

