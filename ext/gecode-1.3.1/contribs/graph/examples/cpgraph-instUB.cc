
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
/** \brief Example to test the intantiateUB method of OutAdjSetsGraphView 
 * \ingroup Examples
 * */
class CPGraphInstUB: public Example {
        private:
                OutAdjSetsGraphView g1;
                OutAdjSetsGraphView g2;
        public: 
                /// Constructor with unused options
                CPGraphInstUB(const Options& opt): g1(this,loadGraph("g1.txt")), g2(this,loadGraph("g1.txt")){
                        cout << g1 << endl;
                        cout << g2 << endl;
                        g2.instantiateUB(this);
                        g1.distrib(this);

                }
                /// Constructor for cloning \a s
                CPGraphInstUB(bool share, CPGraphInstUB& s) : Example(share,s){
                        g1.update(this, share, s.g1);
                        g2.update(this, share, s.g2);
                }
                /// Copying during cloning
                virtual Space*
                        copy(bool share) {
                                return new CPGraphInstUB(share,*this);
                        }
                /// Print the solution
                virtual void
                        print(void) {
                                std::cout << std::endl << "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"<<std::endl;
                                std::cout << "g1 = " << g1 << std::endl;
                                std::cout << "g2 = " << g2 << std::endl;
                                std::cout << std::endl << "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"<<std::endl;
                        }
};
/** \brief Example to test the intantiateUB method of NodeArcSetsGraphView 
 * \ingroup Examples
 * */
class CPGraphInstUB2vars: public Example {
        private:
                ArcNode *an ; //used for member init  
                NodeArcSetsGraphView g1;
                NodeArcSetsGraphView g2;
        public: 
                /// Constructor with unused options
                CPGraphInstUB2vars(const Options& opt): an(new ArcNode(loadGraph("g1.txt").first.size())), g1(this,an,loadGraph("g1.txt")), g2(this,an,loadGraph("g1.txt")) {
                        g2.instantiateUB(this);
                        g1.distrib(this);
                }
                /// Constructor for cloning \a s
                CPGraphInstUB2vars(bool share, CPGraphInstUB2vars& s) : Example(share,s){
                        g1.update(this, share, s.g1);
                        g2.update(this, share, s.g2);
                }
                /// Copying during cloning
                virtual Space*
                        copy(bool share) {
                                return new CPGraphInstUB2vars(share,*this);
                        }
                /// Print the solution
                virtual void
                        print(void) {
                                std::cout << std::endl << "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"<<std::endl;
                                std::cout << "g1 = " << g1 << std::endl;
                                std::cout << "g2 = " << g2 << std::endl;
                                std::cout << std::endl << "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"<<std::endl;
                        }
};
int
main(int argc, char** argv) {
  Options opt("CPGraphInstUB");
  opt.icl        = ICL_DOM;
  opt.solutions        = 0;
  opt.parse(argc,argv);
  if (opt.size == 2){
          Example::run<CPGraphInstUB2vars,DFS>(opt);
  }else{
          Example::run<CPGraphInstUB,DFS>(opt);
  }
  return 0;
}
