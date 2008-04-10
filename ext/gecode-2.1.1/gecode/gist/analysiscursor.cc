/*
 *  Main authors:
 *     Guido Tack <tack@gecode.org>
 *
 *  Copyright:
 *     Guido Tack, 2006
 *
 *  Last modified:
 *     $Date: 2008-02-06 18:48:22 +0100 (Wed, 06 Feb 2008) $ by $Author: schulte $
 *     $Revision: 6102 $
 *
 *  This file is part of Gecode, the generic constraint
 *  development environment:
 *     http://www.gecode.org
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */

#include "gecode/gist/analysiscursor.hh"

#include "gecode/int.hh"

namespace Gecode { namespace Gist {

  void
  AnalysisCursor::processTopDown(void) {
    VisualNode* n = node();
    if (n->getStatus() == UNDETERMINED)
      return;
    Space* s = n->getSpace();
    Reflection::VarMap vm;
    s->getVars(vm, false);
    int h = 0;
    for (Reflection::ActorSpecIter si(s, vm); si(); ++si) {}
    for (Reflection::VarMapIter vmi(vm); vmi(); ++vmi) {
      if (vmi.spec().vti() == Int::IntVarImp::vti) {
        Reflection::IntArrayArgRanges ia(vmi.spec().dom()->toIntArray());
        h += Iter::Ranges::size(ia);
      }
    }
    n->setHeat(h);
    delete s;    
  }

  void
  AnalysisCursor::moveDownwards(void) {
    NodeCursor<VisualNode>::moveDownwards();
    processTopDown();
  }

  void
  AnalysisCursor::moveSidewards(void) {
    NodeCursor<VisualNode>::moveSidewards();
    processTopDown();
  }

  void
  AnalysisCursor::processCurrentNode(void) {
    VisualNode* n = node();
    if (n->getStatus() == UNDETERMINED)
      return;
    VisualNode* p = n->getParent();
    if (p == NULL) {
      n->setHeat(0);
    } else {
      int h = p->getHeat() - n->getHeat();
      n->setHeat(h);
      maxHeat = std::max(maxHeat, h);
      minHeat = std::min(minHeat, h);
    }
  }

  AnalysisCursor::AnalysisCursor(VisualNode* root, int& min, int& max)
  : NodeCursor<VisualNode>(root), minHeat(min), maxHeat(max) {
    minHeat = Gecode::Int::Limits::max;
    maxHeat = 0;
    processTopDown();
  }

  DistributeCursor::DistributeCursor(VisualNode* root, int min, int max)
  : NodeCursor<VisualNode>(root), minHeat(min), maxHeat(max) {}

  void
  DistributeCursor::processCurrentNode(void) {
    VisualNode* n = node();
    if (n->getParent() != NULL) {
      int h = static_cast<int>(((static_cast<double>(n->getHeat()) - static_cast<double>(minHeat)) / 
               (static_cast<double>(maxHeat)-static_cast<double>(minHeat))) * 255);
      n->setHeat(h);
    } else {
      n->setHeat(0);
    }
  }

}}

// STATISTICS: gist-any
