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

#ifndef __GECODE_MAP_HH__
#define __GECODE_MAP_HH__

#define TRACE_MAP(A) 

#if !defined(GECODE_STATIC_LIBS) && \
    (defined(__CYGWIN__) || defined(__MINGW32__) || defined(_MSC_VER))

#ifdef GECODE_BUILD_MAP
#define GECODE_MAP_EXPORT __declspec( dllexport )
#else
#define GECODE_MAP_EXPORT __declspec( dllimport )
#endif

#else

#define GECODE_MAP_EXPORT

#endif

#include "support/shared-array.hh"
#include "set.hh"
#include "int.hh"

using namespace std;
using namespace Gecode::Set;
using namespace Gecode::Int;

//The header file "int/distinct.hh" is needed 
//for the branch function uses BvarSel vars, BvalSel vals.
//This is temporary until branching has been integrated with  
//the branching Gecode schema.
#include "int/branch.hh" 
#include "int/count.hh" 
#include "var.icc"

using namespace Gecode::Map;
using namespace Gecode;

#include "constraints.hh"

using namespace Gecode::Int::Count;


#endif //__GECODE_MAP_HH

