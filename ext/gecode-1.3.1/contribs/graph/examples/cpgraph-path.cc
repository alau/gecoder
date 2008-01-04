
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

#include "examples/support.hh"
#include "graphutils.icc"
#include "graph.hh"
using namespace Gecode::Graph;

/** \brief Example to test the simple Path propagator with OutAdjSetsGraphView 
 * \ingroup Examples
 * */
class CPGraphSimplePath: public Example {
        private:
                OutAdjSetsGraphView g1;
        public: 
                /// Constructor sith unused options
                CPGraphSimplePath(const Options& opt): g1(this,loadGraph("g2.txt")){
                        path(this,g1,0,5);
                        g1.distrib(this);
                }
                /// Constructor for cloning \a s
                CPGraphSimplePath(bool share, CPGraphSimplePath& s) : Example(share,s){
                        g1.update(this, share, s.g1);
                }
                /// Copying during cloning
                virtual Space*
                        copy(bool share) {
                                return new CPGraphSimplePath(share,*this);
                        }
                /// Print the solution
                virtual void
                        print(void) {
                                std::cout << "\tg1 = " << g1 << std::endl;
                        }
};
/** \brief Example to test the simple Path propagator with NodeArcSetsGraphView 
 * \ingroup Examples
 * */
class CPGraphSimplePath2vars: public Example {
        private:
                NodeArcSetsGraphView g1;
        public: 
                /// Constructor sith unused options
                CPGraphSimplePath2vars(const Options& opt): g1(this,new ArcNode(loadGraph("g2.txt").second),loadGraph("g2.txt")){
                        path(this,g1,0,5);
                        g1.distrib(this);
                }
                /// Constructor for cloning \a s
                CPGraphSimplePath2vars(bool share, CPGraphSimplePath2vars& s) : Example(share,s){
                        g1.update(this, share, s.g1);
                }
                /// Copying during cloning
                virtual Space*
                        copy(bool share) {
                                return new CPGraphSimplePath2vars(share,*this);
                        }
                /// Print the solution
                virtual void
                        print(void) {
                                std::cout << "Solution \tg1 = " <<std::endl<<  g1 << std::endl;
                        }
};
int
main(int argc, char** argv) {
  Options opt("CPGraphSimplePath");
  opt.icl        = ICL_DOM;
  opt.solutions        = 0;
  opt.parse(argc,argv);
  if (opt.size == 2){
          Example::run<CPGraphSimplePath2vars,DFS>(opt);
  }else{
          Example::run<CPGraphSimplePath,DFS>(opt);
  }
  return 0;
}
