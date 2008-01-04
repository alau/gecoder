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

#include <iostream>
#include <iomanip>

#include <cstdlib>
#include <cstring>

#include "kernel.hh"
#include "search.hh"

#include "examples/support.hh"
#include "examples/timer.hh"
#include "minimodel.hh"
#include "map.hh"
#include "matching/mono.hh"
#include "int.hh"
#include "set.hh"
#include "graph.hh"
#include "graphutils.icc"

using namespace Gecode::Map;

/**
 * 
 * \brief Graph isomorphism problem
 * \ingroup MatchingExamples
 * 
 *  Treats the graph isomorphism problem between two ground graphs
 *  and finds the corresponding function.
 */
//@{
class Isomorphism : public Example {
   private:
      OutAdjSetsGraphView P;
      OutAdjSetsGraphView T;
      OutAdjSetsGraphView t;
      MapVar M;

   public:
      Isomorphism(const Options& opt, const string pattern, const string target) 
	 : P(this,loadAmalfi(pattern)), T(this, loadAmalfi(target)), t(this, loadAmalfi(target)),
	 M(this, P.nodes, T.nodes) 
	 {
	    TRACE_MAP(cout << "Pattern graph : " << endl);
	    TRACE_MAP(cout << P << endl);
	    TRACE_MAP(cout << "Target graph : " << endl);
	    TRACE_MAP(cout << T << endl);

	    P.instantiateUB(this);
	    //T.instantiateUB(this);

	    //isomorphism performing propagation
	    isoInduced(this, P, T, M);
	    branch(this, M, BVAR_SIZE_MIN, BVAL_MIN);  
	 }

      /// Constructor for cloning \a s
      Isomorphism(bool share, Isomorphism& s) : Example(share,s)
      {
	 TRACE_MAP(cout << "update" << endl);
	 P.update(this,share,s.P);
	 T.update(this,share,s.T);
	 t.update(this,share,s.t);
	 M.update(this,share,s.M); 
	 TRACE_MAP(M.print());
	 TRACE_MAP(cout << "endupdate" << endl);
      } 

      /// Perform copying during cloning
      virtual Space*
	 copy(bool share) {
	    TRACE_MAP(cout << "copying" << endl);
	    return new Isomorphism(share,*this);
	 }

      /// Print solution
      virtual void print(void) {
	 cout << "\n----------\n----------\nSOLUTION :\n----------\n----------" << endl;
	 for (int i=0; i<(int) M.maxInitDomSize(); i++)
	 {
	    cout <<"(" << i << ", " << M.imageAssigned(i) << ")";
	 }
	 cout << endl;
      }


};
//@}
   int main(int argc, char** argv) {
      if (argc<3)
	 cout << argv[0] << " <Pattern file> <Target file>" << endl;
      Options o("Isomorphism");
      o.solutions = 0;
      o.iterations = 200;
      o.size       = 100;
      o.c_d        = 5;
      //o.parse(argc,argv);
      Timer t;
      int i = o.solutions;
      t.start();
      string s1(argv[1]);
      string s2(argv[2]);
      Isomorphism* s = new Isomorphism(o, s1, s2);
      DFS<Isomorphism> e(s,o.c_d,o.a_d);
	delete s;
	do {
	  Example* ex = e.next();
	  if (ex == NULL)
	    break;
	  ex->print();
	  delete ex;
	} while (--i != 0);
	Search::Statistics stat = e.statistics();
	cout << endl;
	cout << "Summary" << endl
	     << "\truntime:      " << t.stop() << endl
	     << "\tsolutions:    " << abs(static_cast<int>(o.solutions) - i) << endl
	     << "\tpropagations: " << stat.propagate << endl
	     << "\tfailures:     " << stat.fail << endl
	     << "\tclones:       " << stat.clone << endl
	     << "\tcommits:      " << stat.commit << endl
	     << "\tpeak memory:  " 
	     << static_cast<int>((stat.memory+1023) / 1024) << " KB"
	     << endl;

      return 0;
   }

// STATISTICS: example-any

