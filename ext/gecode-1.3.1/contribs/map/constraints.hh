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


#ifndef GECODE_MAP_PROP
#define GECODE_MAP_PROP
#include "map.hh"

namespace Gecode{
/**
 * \defgroup TaskActorMapMPP MapVar modelisation function
 *
 * This module contains functions posting MapVar propagators. 
 * 
 * 
 */
   /*@{*/

   //TODO : branching format should be merged with the Gecode branching schema.
   //This is a temporary solution.
   /// Branch on \a M seen as an array of IntVar.
   void branch(Space *home, Gecode::Map::MapVar M, BvarSel vars, BvalSel vals);
   /// \a M is injective.
   void injective(Gecode::Space *home, Gecode::Map::MapVar M);
}
/*@}*/

#include "constraints.icc"

#endif
