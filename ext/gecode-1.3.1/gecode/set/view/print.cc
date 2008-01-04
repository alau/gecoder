/*
 *  Main authors:
 *     Guido Tack <tack@gecode.org>
 *     Gabor Szokoli <szokoli@gecode.org>
 *
 *  Copyright:
 *     Guido Tack, 2004, 2005
 *     Gabor Szokoli, 2004
 *
 *  Last modified:
 *     $Date: 2006-04-11 15:58:37 +0200 (Tue, 11 Apr 2006) $ by $Author: tack $
 *     $Revision: 3188 $
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

#include "gecode/set.hh"

using namespace Gecode::Set;
using namespace Gecode::Int;

namespace Gecode { namespace Set {

/* 
 * Printing a bound
 *
 */
template <class I>
static void
printBound(std::ostream& os, I& r) {
  os << '{';
  while (r()) {
    if (r.min() == r.max()) {
      os << r.min();
    } else if (r.min()+1 == r.max()) {
      os << r.min() << " " << r.max();
    } else {
      os << r.min() << "#" << r.max();
    }
    ++r;
    if (!r()) break;
    os << ' ';
  }
  os << '}';
}
    
/*
 * Printing a variable or view from the data generaly available
 *
 */
template <class IL, class IU>
static void
printVar(std::ostream& os, const bool assigned, IL& lb, IU& ub,
	 unsigned int cardMin, unsigned int cardMax) {
  if (assigned) {
    printBound(os, ub);
    os << "#" << cardMin;
  } else {
    os << "_{";
    printBound(os,lb);
    os << "..";
    printBound(os,ub);
    os << "}";
    if (cardMin==cardMax) {
      os << "#" <<cardMin;
    } else {
      os << "#{" << cardMin << "," << cardMax << "}";
    }
  }
}

}}

std::ostream&
operator<<(std::ostream& os, const SetVarImp& x) {
  LubRanges<SetVarImp*> ub(&x);
  GlbRanges<SetVarImp*> lb(&x);
  printVar(os, x.assigned(), lb, ub, x.cardMin(), x.cardMax()) ;
  return os;
}

std::ostream&
operator<<(std::ostream& os, const SetView& x) {
  LubRanges<SetView> ub(x);
  GlbRanges<SetView> lb(x);
  printVar(os, x.assigned(), lb, ub, x.cardMin(), x.cardMax()) ;
  return os;
}

std::ostream&
operator<<(std::ostream& os, const EmptyView&) {
  return os << "{}#0";
}

std::ostream&
operator<<(std::ostream& os, const UniverseView&) {
  return os << "{" << Gecode::Limits::Set::int_min << "#"
	    << Gecode::Limits::Set::int_max << "}#"
	    << Gecode::Limits::Set::card_max;
}

std::ostream&
operator<<(std::ostream& os, const ConstantView& s) {
  return os << "{?}#?";
}

std::ostream&
operator<<(std::ostream& os, const SingletonView&) {
  return os << "{?}#1";
}

// STATISTICS: set-var

