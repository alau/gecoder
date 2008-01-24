/*
 *  Main authors:
 *     Guido Tack <tack@gecode.org>
 *
 *  Copyright:
 *     Guido Tack, 2006
 *
 *  Last modified:
 *     $Date: 2006-08-17 11:46:13 +0200 (Thu, 17 Aug 2006) $ by $Author: tack $
 *     $Revision: 3544 $
 *
 *  This file is part of Gecode, the generic constraint
 *  development environment:
 *     http://www.gecode.org
 *
 *  See the file "LICENSE" for information on usage and
 *  redistribution of this file, and for a
 *     DISCLAIMER OF ALL WARRANTIES.
 *
 */

#include "gecode/set/projectors.hh"

namespace Gecode {

  void
  ProjectorSet::add(const Projector& p) {
    _ps.ensure(_count+1);    
    new (&_ps[_count]) Projector(p);
    for (int i=_count+1; i<_ps.size(); i++)
      new (&_ps[i]) Projector();
    _count++;

    _arity = std::max(_arity, p.arity());
  }

  void
  ProjectorSet::scope(Support::DynamicArray<int>& s) const {
    // Clear out s
    for (int i=_arity+1; i--;)
      s[i] = Set::PC_SET_ANY + 1;

    // Collect scope from individual projectors
    for (int i=_count; i--; ) {
      _ps[i].scope(s);
    }
  }

  ExecStatus
  ProjectorSet::check(Space* home, ViewArray<Set::SetView>& x) {
    ExecStatus es = ES_SUBSUMED;
    for (int i=0; i<_count; i++) {
      ExecStatus es_new = _ps[i].check(home, x);
      switch (es_new) {
      case ES_FAILED:
	return ES_FAILED;
      case ES_SUBSUMED:
	break;
      default:
	es = es_new;
	break;
      }
    }
    return es;
  }

}

// STATISTICS: set-prop
