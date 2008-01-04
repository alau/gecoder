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
 * \brief %Example: Execution stress test
 *
 * \ingroup Example
 *
 */
class StressExec : public Example {
protected:
  /// Variables
  IntVarArray x;
public:
  /// The actual problem
  StressExec(const Options& opt)
    : x(this,2,0,opt.size) {

    rel(this, x[0], IRT_LE, x[1]);
    rel(this, x[1], IRT_LE, x[0]);

  }

  /// Constructor for cloning \a s
  StressExec(bool share, StressExec& s) : Example(share,s) {
    x.update(this, share, s.x);
  }

  /// Perform copying during cloning
  virtual Space*
  copy(bool share) {
    return new StressExec(share,*this);
  }

  /// Print solution
  virtual void
  print(void) {}
};

/** \brief Main-function
 *  \relates StressExec
 */
int
main(int argc, char** argv) {
  Options opt("StressExec");
  opt.iterations = 20;
  opt.size       = 1000000;
  opt.parse(argc,argv);
  Example::run<StressExec,DFS>(opt);
  return 0;
}

// STATISTICS: example-any

