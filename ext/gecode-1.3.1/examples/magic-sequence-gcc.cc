/*
 *  Main authors:
 *     Christian Schulte <schulte@gecode.org>
 *
 *  Copyright:
 *     Christian Schulte, 2001
 *
 *  Last modified:
 *     $Date: 2006-08-04 16:06:52 +0200 (Fri, 04 Aug 2006) $ by $Author: schulte $
 *     $Revision: 3517 $
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
#include "gecode/minimodel.hh"

/**
 * \brief %Example: Magic sequence
 *
 * Find a magic sequence of length \f$n\f$. A magic sequence of
 * length \f$n\f$ is a sequence \f[x_0,x_1, \ldots, x_{n-1}\f]
 * of integers such that for every \f$i=0,\ldots,n-1\f$:
 *  - \f$x_i\f$ is an integer between \f$0\f$ and \f$n-1\f$.
 *  - the number \f$i\f$ occurs exactly \f$x_i\f$ times in the sequence.
 *
 * \ingroup Example
 *
 */
class MagicSequence : public Example {
private:
  /// Length of sequence
  const int n;
  /// Sequence
  IntVarArray s;
public:
  /// The actual model
  MagicSequence(const Options& opt)
    : n(opt.size), s(this,n,0,n-1) {
    gcc(this, s, s, 0, n-1, ICL_BND);
    IntArgs c(n);
    for (int j = n; j--; )
      c[j] = j-1;
    linear(this, c, s, IRT_EQ, 0);
    branch(this, s, BVAR_NONE, BVAL_SPLIT_MAX);
  }

  /// Constructor for cloning \a e
  MagicSequence(bool share, MagicSequence& e) : Example(share,e), n(e.n) {
    s.update(this, share, e.s);
  }
  /// Copy during cloning
  virtual Space*
  copy(bool share) {
    return new MagicSequence(share,*this);
  }
  /// Print sequence
  virtual
  void print(void) {
    std::cout << "\t";
    for (int i = 0; i<n; i++) {
      std::cout << s[i] << ", ";
      if ((i+1) % 20 == 0)
	std::cout << std::endl << "\t";
    }
    std::cout << std::endl;
  }

};

/** \brief Main-function
 *  \relates MagicSequence
 */
int
main(int argc, char** argv) {
  Options opt("MagicSequence");
  opt.solutions  = 0;
  opt.iterations = 4;
  opt.size       = 500;
  opt.parse(argc,argv);
  Example::run<MagicSequence,DFS>(opt);
  return 0;
}

// STATISTICS: example-any

