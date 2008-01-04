
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
/** \brief Most basic example possible for OutAdjSetsGraphView
 *
 * instantiate the View and distribute in a naive way.
 * \ingroup Examples
 */
class CPGraphBasic: public Example {
        private:
                OutAdjSetsGraphView g1;
        public: 
                /// Constructor with unused options
                CPGraphBasic(const Options& opt): g1(this,loadGraph("g1.txt")){
                        cout << g1 << endl;
                        g1.distrib(this);
                }
                /// Constructor for cloning \a s
                CPGraphBasic(bool share, CPGraphBasic& s) : Example(share,s){
                        g1.update(this, share, s.g1);
                }
                /// Copying during cloning
                virtual Space*
                        copy(bool share) {
                                return new CPGraphBasic(share,*this);
                        }
                /// Print the solution
                virtual void
                        print(void) {
                                std::cout << "\tg1 = " << g1 << std::endl;
                        }
};
/** \brief Most basic example possible for NodeArcSetsGraphView
 *
 * instantiate the View and distribute in a naive way.
 * \ingroup Examples
 */
class CPGraphBasic2vars: public Example {
        private:
                NodeArcSetsGraphView g1;
        public: 
                /// Constructor with unused options
                CPGraphBasic2vars(const Options& opt): g1(this,new ArcNode(loadGraph("g1.txt").second),loadGraph("g1.txt")){
                        g1.distrib(this);
                }
                /// Constructor for cloning \a s
                CPGraphBasic2vars(bool share, CPGraphBasic2vars& s) : Example(share,s){
                        g1.update(this, share, s.g1);
                }
                /// Copying during cloning
                virtual Space*
                        copy(bool share) {
                                return new CPGraphBasic2vars(share,*this);
                        }
                /// Print the solution
                virtual void
                        print(void) {
                                std::cout << "\tg1 = " << g1 << std::endl;
                        }
};
int
main(int argc, char** argv) {
  Options opt("CPGraphBasic");
  opt.icl        = ICL_DOM;
  opt.solutions        = 0;
  opt.parse(argc,argv);
  if (opt.size == 2){
          Example::run<CPGraphBasic2vars,DFS>(opt);
  }else{
          Example::run<CPGraphBasic,DFS>(opt);
  }
  return 0;
}
