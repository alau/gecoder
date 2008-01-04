/*
 *  Main authors:
 *     Christian Schulte <schulte@gecode.org>
 *
 *  Copyright:
 *     Christian Schulte, 2001
 *
 *  Last modified:
 *     $Date: 2006-08-03 13:51:17 +0200 (Thu, 03 Aug 2006) $ by $Author: schulte $
 *     $Revision: 3506 $
 *
 *  This file is part of Gecode, the generic constraint
 *  development environment:
 *     http://www.gecode.org
 *
 *  See the file "LICENSE" for information on usage and
 *  redistribution of this file, and for a
 *     DISCLAIMER OF ALL WARRANTIES.
 *
 */

#include "examples/support.hh"

/**
 * \brief %Example: Domain stress test
 *
 * \ingroup Example
 *
 */
class StressDomain : public Example {
protected:
  /// Variables
  IntVarArray x;
public:
  /// The actual problem
  StressDomain(const Options& opt)
    : x(this,5,0,5*opt.size) {

    // Cut holes: expand
    for (int i = 5; i--; ) {
      for (unsigned int j = 0; j <= 5*opt.size; j++)
	rel(this, x[i], IRT_NQ, 5*j);
      for (unsigned int j = 0; j <= 5*opt.size; j++)
	rel(this, x[i], IRT_NQ, 5*j+2);
      for (unsigned int j = 0; j <= 5*opt.size; j++)
	rel(this, x[i], IRT_NQ, 5*j+4);
    }
    // Contract
    for (unsigned int j = 0; j <= 5*opt.size/2; j++)
      for (unsigned int i = 5; i--; ) {
	rel(this, x[i], IRT_GQ, 5*j);
	rel(this, x[i], IRT_LQ, 5*(j + (5*opt.size/2)));
      }
  }

  /// Constructor for cloning \a s
  StressDomain(bool share, StressDomain& s) : Example(share,s) {
    x.update(this, share, s.x);
  }

  /// Perform copying during cloning
  virtual Space*
  copy(bool share) {
    return new StressDomain(share,*this);
  }

  /// Print solution
  virtual void
  print(void) {}
};

/** \brief Main-function
 *  \relates StressDomain
 */
int
main(int argc, char** argv) {
  Options opt("StressDomain");
  opt.iterations = 200;
  opt.size       = 1000;
  opt.parse(argc,argv);
  Example::run<StressDomain,DFS>(opt);
  return 0;
}

// STATISTICS: example-any

