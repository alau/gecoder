/* -*- mode: C++; c-basic-offset: 2; indent-tabs-mode: nil -*- */
/*
 *  Main authors:
 *     Christian Schulte <schulte@gecode.org>
 *
 *  Copyright:
 *     Christian Schulte, 2003
 *
 *  Last modified:
 *     $Date: 2008-01-19 13:19:23 +0100 (Sat, 19 Jan 2008) $ by $Author: schulte $
 *     $Revision: 5916 $
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

#include "gecode/search.hh"

namespace Gecode { namespace Search {

  /*
   * The invariant maintained by the engine is:
   *   For all nodes stored at a depth less than mark, there
   *   is no guarantee of betterness. For those above the mark,
   *   betterness is guaranteed.
   *
   * The engine maintains the path on the stack for the current
   * node to be explored.
   *
   */

  BabEngine::ExploreStatus
  BabEngine::explore(Space*& s1, Space*& s2) {
    start();
    /*
     * Upon entry, cur can be either NULL or set to the initial
     * space. For the initial case, es is also ES_CONSTRAIN.
     *
     * Otherwise (that is, cur == NULL), the actions depend on
     * es. In case es is ES_CONSTRAIN, a space on stack has been
     * constrained. Whether this is succesful recomputation finds
     * out. In any case, the stack is not allowed to be moved to
     * the next node.
     *
     * In case es is ES_SOLUTION, the stack must be moved to the next
     * node and recomputation is to be performed.
     */
    while (true) {
      assert((es == ES_SOLUTION) || (cur == NULL));
      if (stop(stacksize())) {
        s1 = NULL;
        return ES_SOLUTION;
      }
      if (cur == NULL) {
        if (es == ES_CONSTRAIN) {
          es = ES_SOLUTION;
          goto same;
        }
        do {
          if (!rcs.next(*this)) {
            s1 = NULL;
            return ES_SOLUTION;
          }
          {
            int l = rcs.lc(s1);
            if (l < mark) {
              es = ES_CONSTRAIN;
              mark = l;
              s2 = best;
              return ES_CONSTRAIN;
            }
          }
        same:
          cur = rcs.recompute<true>(d,*this);
        } while (cur == NULL);
        EngineCtrl::current(cur);
      }
      switch (cur->status(propagate)) {
      case SS_FAILED:
        fail++;
        delete cur;
        cur = NULL;
        EngineCtrl::current(NULL);
        break;
      case SS_SOLVED:
        delete best;
        best = cur;
        mark = rcs.entries();
        s1 = best->clone();
        clone++;
        cur = NULL;
        EngineCtrl::current(NULL);
        return ES_SOLUTION;
      case SS_BRANCH:
        {
          Space* c;
          if ((d == 0) || (d >= c_d)) {
            c = cur->clone();
            clone++;
            d = 1;
          } else {
            c = NULL;
            d++;
          }
          const BranchingDesc* desc = rcs.push(cur,c);
          EngineCtrl::push(c,desc);
          cur->commit(desc,0);
          commit++;
          break;
        }
      default:
        GECODE_NEVER;
      }
    }
    return ES_SOLUTION;
  }




  BAB::BAB(Space* s, unsigned int c_d, unsigned int a_d, Stop* st, size_t sz)
    : e(c_d,a_d,st,sz) {
    unsigned long int p = 0;
    Space* c = (s->status(p) == SS_FAILED) ? NULL : s->clone(true);
    e.init(c);
    e.propagate += p;
    e.current(s);
    e.current(NULL);
    e.current(c);
    if (c == NULL)
      e.fail += 1;
  }

  bool
  BAB::stopped(void) const {
    return e.stopped();
  }

  Statistics
  BAB::statistics(void) const {
    Statistics s = e;
    s.memory += e.stacksize();
    return s;
  }

}}

// STATISTICS: search-any
