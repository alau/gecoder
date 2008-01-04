
/*
 *  Main authors:
 *     Grégoire Dooms <dooms@info.ucl.ac.be>
 *
 *  Copyright:
 *     Grégoire Dooms (Université catholique de Louvain), 2005
 *
 *  Last modified:
 *     $Date: 2005-11-29 10:57:21 +0100 (Tue, 29 Nov 2005) $
 *     $Revision: 271 $
 *
 *  This file is part of CP(Graph)
 *
 *  See the file "contribs/graph/LICENSE" for information on usage and
 *  redistribution of this file, and for a
 *     DISCLAIMER OF ALL WARRANTIES.
 *
 */

#ifndef PATH_HH
#define PATH_HH

#include "kernel.hh"
#include "int.hh"
#include <map>
#include <boost/utility.hpp>
//using namespace Gecode;
//using namespace std;
//using namespace boost;

namespace Gecode { namespace Graph {
/** \brief Propagator for the simple path constraint
 * 
 * \relates PathBoundsGraphs
 */
template <class GView>
class PathPropag : public  Propagator {
        protected:
                GView g;
                int start, end;
        public :
                PathPropag(Space* home, bool share, PathPropag& p);
        /// Destructor for cancelling 
                ~PathPropag(void);
        /// Constructor for posting 
                PathPropag(Space* home, GView g, int st, int en);
        /// perform the copy upon space cloning 
                virtual Actor*      copy(Space*,bool);
        // return the cost of propagation
                virtual PropCost    cost(void) const;
        /// perform the filtering 
                virtual ExecStatus  propagate(Space*);
        /// Post propagator g is a simple path from node \a start to node \a end
                static ExecStatus post(Space* home, GView &g,int start, int end);
};
/** \brief Propagator for the cost-based filtering for a simple-path
 * 
 * \relates PathBoundsGraphs
 */
template <class GView>
class PathCostPropag : public  Propagator {
        protected:
                GView g;///< the graph view on which the propagator is posted
                int start, end; 
                /** todo keep a pointer to the map instead of the map
                 * allocated by  PathCostPropag, and kept through reference counting.
                 * copy increments, destructor decrements and frees if count==0 
                 * --> Use a smart pointer  */
                map <pair<int,int>,int> ecosts; 
                Int::IntView w; ///< the IntView for the total cost of the graph
        public :
                /// Copy constructor for cloning the propagator
                PathCostPropag(Space* home, bool share, PathCostPropag& p);
                /// Destructor 
                ~PathCostPropag(void);
                /// constructor for posting the propagator
                PathCostPropag(Space* home, GView g, int st, int en, const map <pair<int,int>,int> &edgecosts, Int::IntView w);
                /// copy the propagator to new Space
                virtual Actor*      copy(Space*,bool);
                /// cost of propagation
                virtual PropCost    cost(void) const;
                /// perform propagation
                virtual ExecStatus  propagate(Space*);
                /// Posts the propagator g is a path from st to en and according to the edgecosts its total cost is w
                static ExecStatus post(Space* home, GView &g,int start, int end, Int::IntView w, const map <pair<int,int>,int> &edgecosts ) ;
};

/** \brief Propagator for a node degree=1 constraint 
 *
 * each node of the graph has a in/out degree of 1 iff it is part of the graph
 * except for start and end which have resp. only outdegree and indegree equal to 1.
 */
template <class GView>
class PathDegreePropag : public  Propagator {
        protected:
                GView g;
                int start, end;
        public :
                PathDegreePropag(Space* home, bool share, PathDegreePropag& p);
                ~PathDegreePropag(void);
                PathDegreePropag(Space* home, GView &g, int st, int end);
                virtual Actor*      copy(Space*,bool);
                virtual PropCost    cost(void) const;
                virtual ExecStatus  propagate(Space*);
                static ExecStatus post(Space* home, GView &g,int start, int end) ;
};
template <class GView>
void path(Space* home, GView &g, int start, int end, const map <pair<int,int>,int> &edgecosts , IntVar w);

template <class GView>
void path(Space* home, GView &g, int start, int end);

} }
#include "path.icc"
#endif
