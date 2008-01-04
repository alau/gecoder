
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

#ifndef BINARYSIMPLE_HH
#define BINARYSIMPLE_HH
#include "kernel.hh"
//using namespace Gecode;
namespace Gecode { namespace Graph {


/** \brief Base class for binary propagators */
template <class GDV1, PropCond p1, class GDV2, PropCond p2>
class BinaryGraphPropagator: public Propagator {
        protected:
                GDV1 g1;
                GDV2 g2;
                /// Constructor for cloning
                BinaryGraphPropagator(Space* home,  bool share, BinaryGraphPropagator& p);
        public :
                /// Destructor for cancelling 
                virtual ~BinaryGraphPropagator(void);
                /// Constructor for posting
                BinaryGraphPropagator(Space* home, GDV1 &g1, GDV2 &g2);
                /// Tells the estimated cost of propgation
                virtual PropCost cost(void) const;
                /// Post the binary propagator
                static ExecStatus post(Space* home, GDV1 &g1, GDV2 &g2);
};

/** \brief Propagator for the complement graph binary constraint.
 *
 * A graph is the complement of an other if their adj matrices sum to all ones
 */
template <class GDV1, class GDV2>
struct ComplementPropag: public BinaryGraphPropagator<GDV1, Gecode::Graph::PC_GRAPH_ANY, GDV2, Gecode::Graph::PC_GRAPH_ANY> {
        using BinaryGraphPropagator<GDV1, Gecode::Graph::PC_GRAPH_ANY, GDV2, Gecode::Graph::PC_GRAPH_ANY>::g1;
        using BinaryGraphPropagator<GDV1, Gecode::Graph::PC_GRAPH_ANY, GDV2, Gecode::Graph::PC_GRAPH_ANY>::g2;
        using BinaryGraphPropagator<GDV1, Gecode::Graph::PC_GRAPH_ANY, GDV2, Gecode::Graph::PC_GRAPH_ANY>::cost;
        protected:
                /// Constructor for cloning
                ComplementPropag(Space*, bool share, ComplementPropag&);
        public:
                /// Destructor for cancelling 
                virtual ~ComplementPropag(void);
                /// Constructor for posting
                ComplementPropag(Space*,GDV1&,GDV2&);
                /// Perform the filtering steps of the constraint
                virtual ExecStatus  propagate(Space*);
                /// Post the constraint \a g1 = Complement(\a g2)
                static  ExecStatus  post(Space*,GDV1& g1,GDV2& g2);
                /// Copy propagator to new Space
                virtual Actor*  copy(Space* home,bool share) ;
};


/** posts a constraint for g1 is the complement of g2 
 * \ingroup TaskModel
 */
template <class GDV1, class GDV2>
void complement(Space * home, GDV1 &g1, GDV2 &g2);


} } 
#include "binarysimple.icc"
#endif
