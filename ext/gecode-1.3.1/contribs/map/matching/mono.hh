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


#include "graph.hh"
#include "set/int.hh" //used to post the cardinality constraint
#include "set.hh"
#include <boost/tuple/tuple.hpp>

using namespace Gecode::Graph;
using namespace boost;

namespace Gecode { namespace Map {

   /**
    * \defgroup MatchingPropa Matching propagator classes
    *
    * This module contains propagator classes used to implement the monomorphism 
    * and isomorphism constraints. 
    */
   //@{
   /**
    * \brief Propagator for inducing a GraphVar over another one
    *
    * The type \a GView can be any view on a GraphVar.
    * 
    * Limitations : 
    *
    * 1. the second GraphVar must be ground (TODO in CP(Map) 0.2)
    *
    */
   template <class GView>
      class InducedSubgraph : public Propagator {
	 protected:
	    ///Represent the induced graph
	    GView gp;
	    ///*ground* GraphVar representing the structure 
	    GView gt;
	    ///Constructor for cloning \a p
	    InducedSubgraph(Space*, bool share, InducedSubgraph &p);

	 public:
	    ///Constructor for creation 
	    InducedSubgraph(Space* home, GView g1, GView g2);
	    ///Destructor 
	    ~InducedSubgraph();

	    /// Create copy during cloning
	    virtual Actor*      copy(Space*,bool);
	    /// Perform propagation
	    virtual ExecStatus  propagate(Space*);
	    /// Cost function 
	    virtual PropCost    cost(void) const;
	    /// Post propagator 
	    static  ExecStatus  post(Space* home, GView g1, GView g2);
      };

   /**
    * \brief Propagator for \f$ (i,j) \in Arcs(P) \rightarrow (M(i),M(j)) \in Arcs(T) \f$ 
    *
    * The type \a GView can be any view on a GraphVar.
    *
    * Limitations : 
    *
    * 1. class Gview must be class OutAdjSetsGraphView (FIX in CP(Map) 0.2)
    *
    */
   template <class GView>
      class ImplyArcs : public Propagator {
	 protected:
	    ///Represents P
	    GView gp;
	    ///Represents T
	    GView gt;
	    ///Represents the mapping
	    MapVar M;
	    ///Constructor for cloning \a p
	    ImplyArcs(Space*, bool share, ImplyArcs &p);

	 public:
	    ///Constructor for creation 
	    ImplyArcs(Space* home, GView P, GView T, MapVar M);
	    ///Destructor
	    ~ImplyArcs();

	    /// Create copy during cloning
	    virtual Actor*      copy(Space*,bool);
	    /// Perform propagation
	    virtual ExecStatus  propagate(Space*);
	    /// Cost function 
	    virtual PropCost    cost(void) const;
	    /// Post propagator 
	    static  ExecStatus  post(Space* home, GView P, GView T, MapVar M);

      };

   /**
    * \brief Propagator for \f$ (i,j) \in Arcs(P) \rightarrow (M(i),M(j)) \in Arcs(T) \f$ 
    *        where P and T are induced 
    *
    * The type \a GView can be any view on a GraphVar.
    *
    * Limitations : 
    *
    * 1. Only checking is performed 
    *
    */

   template <class GView>
      class MonoInduced : public Propagator {
	 private:
	    pair<vector<int>,vector<pair<int,int> > > extractUB(GView g1); 
	    void initS(Space *home);
	    void initlast(Space *home);
	    void difflast(map<int,vector<int> > &p);
	    void printS(void);
	    void printdifflast(map<int, vector<int> >& diff);
	    void printlast();
	    int computeSOut(int a, int b);
	    int computeSIn(int a, int b);
	    void putS(int a, int b, int v, map<int,int> &S);
	    int getS(int a, int b, map<int,int> &S);
	    void decS(int a, int b, map<int,int> &S);
	    ModEvent _propNeighOut(Space *home, int i, int a);
	    ModEvent _propNeighIn(Space *home, int i, int a);
	    ModEvent _propNeighOutB(Space *home, int i, int a);
	    ModEvent _propNeighInB(Space *home, int i, int a);

	    vector<int> computeLeftInit(Space* home, GView g);
	 protected:
	    ///Represents P
	    GView gp;
	    ///Represents T
	    GView gt;
	    ///Represents the mapping
	    MapVar M;
	    ///Represents the ground structure of P
	    GView gp_ground;
	    ///Represents the ground structure of T
	    GView gt_ground;
	    ///Represents the domain of M at the end of the preivous propagation step.
	    vector<pair<int, list<int> > > last;
	    ///\f$ Sin(i,a) = |D(x_i) \cap Vin(a)| \f$
	    map<int, int> Sin; 
	    ///\f$ DSout(i,a) = |D(x_i) \cap Vout(a)| \f$
	    map<int, int> Sout; 
	    ///Has xiInitialization propagation already been done ?
	    bool initdone;
	    //list of nodes not in LB(nodes(P)) -- used to trigger conditional propagation 
	    vector<int> left; 
	    ///Constructor for cloning \a p
	    MonoInduced(Space*, bool share, MonoInduced &p);

	 public:
	    ///Constructor for creation 
	    MonoInduced(Space* home, GView P, GView T, MapVar M);
	    ~MonoInduced();

	    /// Create copy during cloning
	    virtual Actor*      copy(Space*,bool);
	    /// Perform propagation
	    virtual ExecStatus  propagate(Space*);
	    /// Cost function 
	    virtual PropCost    cost(void) const;
	    /// Post propagator 
	    static  ExecStatus  post(Space* home, GView P, GView T, MapVar M);
      };


   //@}

}
}

namespace Gecode {
/**
 * \defgroup MathcingFunctions Matching modelisation functions
 * 
 */
   //@{
   
   ///Provided Nodes(P)=Nodes(T) and T is ground, P is a graph induced on T.  
   template <class GView>
   void inducedSubgraph(Space *, GView P, GView T);

   ///\f$\forall \; (x,y) \; \in Args(P) : (M(x),M(y)) \in Arcs(T)\f$
   template <class GView>
   void implyArcs(Space *, GView P, GView T, MapVar M);

   ///P and T are monomorphic w.r.t injective mapping M
   ///only checking is performed
   template <class GView>
   void mono(Space *, GView P, GView T, MapVar M);

   ///P and T are isomorphic w.r.t. bijective mapping M
   template <class GView>
   void iso(Space *, GView P, GView T, MapVar M);

   ///P and T are isomorphic w.r.t. bijective mapping M
    ///Propagation is performed
   ///Precondition : P and T must be induced. 
   template <class GView>
   void isoInduced(Space *, GView P, GView T, MapVar M);
   
   ///P and T are monomorphic w.r.t. injective mapping M
   ///Propagation is performed
   ///Precondition : P and T must be induced. 
   template <class GView>
   void monoInduced(Space *, GView P, GView T, MapVar M);

   template <class GView>
   void nodes(Space *home, GView g1, SetVar s);

   //@}
   
}


#include "matching/mono.icc"
