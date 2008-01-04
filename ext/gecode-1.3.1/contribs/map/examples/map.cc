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


#include "examples/support.hh"
#include "minimodel.hh"
#include "map.hh"

using namespace Gecode::Map;
/**
 *
* \brief Simple example of using a Mapvar in a script. For now only tells are possible on the MapVar.
 *
 * For extensive examples on MapVars, please refer to matching examples.
 * 
 * Constraint map(Space *home, IntVar I1, IntVar I2) will be implemented in CP(Map) 0.2.
 *
 */
class MapProblem : public Example {
   protected:
      SetVar Dom;
      SetVar Codom;
      MapVar M;
   public:
      MapProblem(const Options& opt) : Dom(this,IntSet::empty,IntSet(1,3)), Codom(this,IntSet::empty,IntSet(1,3)), M(this,Dom,Codom) {
	 branch(this, M, BVAR_SIZE_MIN, BVAL_MIN);  
      }

      /// Constructor for cloning \a s
      MapProblem(bool share, MapProblem& s) : Example(share,s)
      {
	 M.update(this,share,s.M);
      }

      /// Perform copying during cloning
      virtual Space*
	 copy(bool share) {
	    return new MapProblem(share,*this);
	 }

      /// Print solution
      virtual void
	 print(void) {
	    cout << "\n----------\n----------\nSOLUTION :\n----------\n----------" << endl;
	    for (int i=0; i<(int) M.maxInitDomSize(); i++)
	    {
	       cout <<"(" << i << ", " << M.imageAssigned(i) << ")";
	    }
	    cout << endl;
	 }
};

int main(int argc, char** argv) {
  Options opt("MapProblem");
  opt.iterations = 200;
  opt.size       = 100;
  opt.c_d        = 5;
  opt.parse(argc,argv);
  Example::run<MapProblem,DFS>(opt);
  return 0;
}

// STATISTICS: example-any

