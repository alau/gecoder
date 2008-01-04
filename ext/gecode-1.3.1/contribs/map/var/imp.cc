/*
 *  Main authors:
 *     Zampelli Stéphane <sz@info.ucl.ac.be>
 *
 *  Copyright:
 *     Université catholique de Louvain, 2005
 *
 *  Last modified:
 *     $Date$
 *     $Revision$
 *
 *  This file is part of CP(Map)
 *
 *  See the file "LICENSE" for information on usage and
 *  redistribution of this file, and for a
 *     DISCLAIMER OF ALL WARRANTIES.
 *
 */


#include "map.hh"

namespace Gecode { namespace Map {
  
  /// Return copy of not-yet copied variable
  GECODE_MAP_EXPORT MapVar* MapVar::perform_copy(Space* home, bool share)
  {
    return new (home) MapVar(home,share,*this);
  }
}}

GECODE_MAP_EXPORT std::ostream&
operator<<(std::ostream& os, const Gecode::Map::MapVar& x)
{
  for (int i=0; i<x.array.size(); i++) {
    os << (x.array[i]) << endl;
  };

  return os;
}


