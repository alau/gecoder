
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


/*
 * No code, just contains the group definitions of the
 * Doxygen-generated documentation
 */

/**
 * \defgroup TaskProp Programming propagators for graph constraints
 */

/**
 * \defgroup TaskPropViews Graph views used for programming propagators
 * \ingroup TaskProp
 *
 * Graph constraints are posted on graph views ( OutAdjSetsGraphViews and
 * NodeArcSetsGraphViews ). These views provide reflection methods to consult
 * the current state of the domain of the variable(view). Among these
 * reflection methods, you can find iteration methods which return an iterator
 * over one of the bounds of the graph domain.
 * 
 * The views also provide basic and iterator tells for updating the domains.
 * These methods return a ModEvent, a modification event which indicates which
 * part of the domain was changed. These tells must be surrounded by the
 * GECODE_ME_CHECK macro which returns from the propagator as soon as the space
 * is failed as a failed space cannot be used in any later tells.
 * 
 */

/**
 * \defgroup TaskPropIter Additional iteration for graph constraints.
 * \ingroup TaskProp
 *
 * In addition to the iterator reflection and tells provided by the views,
 * generic iteration functions are provided. These functions take one or two
 * graphs and scan their domains. A visitor object is passed as an argument and
 * its callback functions called accordingly. For instance, with
 * scanTwoGraphsCompleteNodeArcs, An node iterator is passed as argument. The
 * function then scans all possible arcs build using couple of nodes in that
 * iterator. A method of the visitor is called according to the
 * presence/absence of this arc in the domains of two graph views. The possible
 * states are None, Lub, and Glb if the arc (resp.) cannot , can, and must be
 * part of the graph. The methods are named after the state of the arc in both
 * graph domains e.g NoneNone or LubGlb. 
 */

/**
 * \defgroup TaskPropGraph Graph data-structures for graph algorithm in propagators and branchings
 * \ingroup TaskProp
 *
 * The CP(Graph) framework also provides the BoundsGraphs class.
 * This class provides a graph data-structure for  both bounds of the graph
 * domain. This allows to easily use graph algorithms in a graph propagator.
 *
 * A propagator defines a class inheriting from BoundsGraphs. In that children
 * class, propagation steps are implemented by using graph algorithms. Then
 * the propagate method of the Propagator calls these methods on an instance
 * of the BoundsGraphs class. The process is examplified in the path
 * constraint.
 *
 * The Boost Graph Library http://www.boost.org/libs/graph/ was chosen for its
 * genericity, adaptability and number of available graph algorihtms.  The
 * graph members of the BoundsGraphs class are encoding the bounds of the graph
 * domain. They have a boost graph interface. 
 */

/** \defgroup TaskModel Modelling problems involving graph variables and
 * constraints.
 *
 * In Gecode, Var is used for modelling, View for propagators and branching and
 * Imp for the underlying implementations.  CP(Graph) uses graph views for all
 * of these tasks. This means the graph views must be used with great caution.
 * When the tells are used in modelling, they must be surrounded by a check for
 * Space failure.  
 *
 * Two constraints specific to graphs are currently available: the complement constraint 
 * and two path constraints.  Constraints are posted on graph views using a function e.g. path and complement.
 * 
 * The two set-based graph views currently available allow you to post set constraints on the underlying set variables.
 * For instance if you wish to constrain the out-degree of node 4 to be 3, you
 * can use the OutAdjSetsGraphView g and post the cardinality set constraint on
 * g.outN[4]: cardinality(this, g.outN[4], 3, g.outN[4].cardMax());
 * 
 * Other graph specific constraints are under investigation. If you wish to
 * design and implement new ones, please contact Grégoire Dooms at
 * dooms@info.ucl.ac.be to avoid duplicate work. 
 */

/** \defgroup TaskModelBranch Programming search heuristics for graph problems.
 * \ingroup TaskModel
 * 
 * UnaryGraphBranching, a class inheriting from Branching is provided with
 * CP(Graph). This class allows to define search heuristics which perform a
 * binary choice of inclusion or exclusion of a node or arc from a single graph
 * view.
 *
 * It uses a BoundsGraphs::branch method  which can use graph algorithms to
 * decide on which node or arc to choose.  This branch method must return a
 * BranchingDesc a description of the branching decision. Two classes are
 * provided for implementing branching Description for the UnaryGraphBranching:
 * GraphBDSingle and GraphBDMultiple. GraphBDSingle should be used if your
 * search heuristic always chooses arcs or always chooses nodes to branch on.
 * If the search tree interleaves choices about the nodes and choices about the
 * arcs, then GraphBDMultiple should be used. See CPGraphSimplePathHeur and
 * PathHeurBoundsG for examples.
 */

/** \defgroup Examples Examples/Tests
 * 
 * Some Examples or tests of the constraints and views are provided too. They
 * are implemented by inheriting from the Examples class.
 */

