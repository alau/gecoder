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

#include <vector>
#include "examples/support.hh"
#include "minimodel.hh"
#include "map.hh"
#include "matching/mono.hh"
#include "int.hh"
#include "set.hh"
#include "graph.hh"
#include "graphutils.icc"

using namespace Gecode::Map;
using namespace Gecode::Graph;
/**
 * \defgroup MatchingExamples Matching Examples
 * 
 * Various matching examples, including graph isomorphism, subgraph monomorphism and
 * approximate graph matching using CP(Graph+Map).
 * 
 */
//@{
/**
 * \brief Approximate graph matching.
 *
 * Finds a monomorphic function between two graph variables.
 *
 * Note that forbdden edges may be declared on the pattern variable.
 */
class ApproximateMatching : public Example {
  private:
    OutAdjSetsGraphView P;
    OutAdjSetsGraphView T;
    OutAdjSetsGraphView p;
    OutAdjSetsGraphView t;
    OutAdjSetsGraphView Pc;
    OutAdjSetsGraphView pc;
    OutAdjSetsGraphView Tc;
    OutAdjSetsGraphView tc;
    MapVar M;

  public:
    ApproximateMatching(const Options& opt) : P(this,loadGraph("g1.txt")), T(this, loadGraph("g2.txt")), 
					      p(this, loadGraph("g1.txt")), t(this, loadGraph("g2.txt")), 
					      Pc(this, P.lubOrder()), pc(this, P.lubOrder()), 
					      Tc(this, T.lubOrder()), tc(this, T.lubOrder()),
					      M(this, P.nodes, T.nodes) 
    {
      TRACE_MAP(cout << "Pattern graph : " << endl);
      TRACE_MAP(cout << P << endl);
      TRACE_MAP(cout << "Target graph : " << endl);
      TRACE_MAP(cout << T << endl);

      vector<int> listOfMandatoryNodes;
      listOfMandatoryNodes.push_back(0);
      vector<pair <int,int> > listOfForbEdges;
      listOfForbEdges.push_back(make_pair(0,1));

      //force mandatory nodes 
      vector<int>::iterator i;
      for (i=listOfMandatoryNodes.begin(); i<listOfMandatoryNodes.end(); i++) {
	TRACE_MAP(cout << "forced : " << *i << endl);
	P._nodeIn(this, *i);
      }

      //force forbidden edges
      int nbrPatternNodes = P.lubOrder();
      for (int i=0; i<nbrPatternNodes; i++) {
	for (int j=0; j<nbrPatternNodes; j++) {
	  if (find(listOfForbEdges.begin(),listOfForbEdges.end(),make_pair(i,j))==listOfForbEdges.end()) {
	    //p_{forb}=(N_p,F_p)
	    TRACE_MAP(cout << "notforbidden " << i << " " << j << endl);
	    pc._arcOut(this, i, j); 
	    Pc._arcOut(this, i, j);
	  }
	  else
	  {
	    //p=(N_p,E_P)
	    TRACE_MAP(cout << "forbidden : " << i << " " << j << endl);
	    p._arcOut(this, i, j); 
	    P._arcOut(this, i, j); 
	  }
	}	
      }

      //Graphs are induced, so that monoInduced can be used.

      t.instantiateUB(this);
      inducedSubgraph(this,T,t);

      p.instantiateUB(this);
      inducedSubgraph(this, P, p);

      //Force Pattern and its forbidden edges represetation
      //to be identical - mandatory for a proper matching.

      rel(this,P.nodes,SRT_EQ,Pc.nodes);

      //Pc must respect the minimal structure of forbidden
      //edges declared.

      pc.instantiateUB(this);
      inducedSubgraph(this, Pc, pc);

      //T and Tc are complement
      //P and Pc are not complement because Pc represent
      //the _subgraph_ of forbidden edges of P. Thus they
      //are complement only if isomorphism is sought.

      complement(this, T, Tc);

      //Monomorphism constraints are posted on the primal model 
      //and on the dual model. Note that the stronger propagator
      //monoInduced can only be posted on P and T since Pc is not 
      //induced.

      //monoInduced(this,P,T,M);
      mono(this,P,T,M);
      mono(this,Pc,Tc,M);

      //Branching is made upon M (viewed as an IntVar array)
      //with a very naive heuristic.
      branch(this, M, BVAR_SIZE_MIN, BVAL_MIN);  

    }

    /// Constructor for cloning \a s
    ApproximateMatching(bool share, ApproximateMatching& s) : Example(share,s)
    {
      TRACE_MAP(cout << "update" << endl);
      P.update(this,share,s.P);
      T.update(this,share,s.T);
      p.update(this,share,s.p);
      t.update(this,share,s.t);
      Pc.update(this,share,s.Pc);
      pc.update(this,share,s.pc);
      Tc.update(this,share,s.Tc);
      tc.update(this,share,s.tc);
      M.update(this,share,s.M); 
      TRACE_MAP(M.print());
      TRACE_MAP(cout << "endupdate" << endl);
    } 

    /// Perform copying during cloning
    virtual Space*
      copy(bool share) {
	TRACE_MAP(cout << "copying" << endl);
	return new ApproximateMatching(share,*this);
      }

    /// Print solution
    virtual void print(void) {
      cout << "\n----------\n----------\nNEW SOL :\n----------\n----------" << endl;
      cout << P << endl;
      cout << T << endl;
      OutAdjSetsGraphView::GlbNodeIterator glbp = P.iter_nodes_LB();
      while (glbp()) {
	cout << "(" << glbp.val() << "," << M.imageAssigned(glbp.val()) << ")";
	++glbp;
      }
      cout << endl;

    }


};
//@}

int main(int argc, char** argv) {
  Options opt("ApproximateMatching");
  opt.icl=ICL_DOM;
  opt.solutions = 0;
  opt.iterations = 200;
  opt.size       = 100;
  opt.c_d        = 5;
  opt.parse(argc,argv);
  Example::run<ApproximateMatching,DFS>(opt);
  return 0;
}

// STATISTICS: example-any

