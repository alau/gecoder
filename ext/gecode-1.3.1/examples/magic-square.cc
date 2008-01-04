/*
 *  Main authors:
 *     Christian Schulte <schulte@gecode.org>
 *
 *  Copyright:
 *     Christian Schulte, 2001
 *
 *  Last modified:
 *     $Date: 2006-04-11 15:58:37 +0200 (Tue, 11 Apr 2006) $ by $Author: tack $
 *     $Revision: 3188 $
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
 * \brief %Example: Magic squares
 *
 * Compute magic squares of arbitrary size
 *
 * \ingroup Example
 *
 */
class MagicSquare : public Example {
private:
  /// Size of magic square
  const int n;
  /// Fields of square
  IntVarArray x;

public:
  /// Post constraints
  MagicSquare(const Options& opt)
    : n(opt.size), x(this,n*n,1,n*n) {
    // Number of fields on square
    const int nn = n*n;

    // Sum of all a row, column, or diagonal
    const int s  = nn*(nn+1) / (2*n);

    // Matrix-wrapper for the square
    MiniModel::Matrix<IntVarArray> m(x, n, n);

    for (int i = n; i--; ) {
	linear(this, m.row(i), IRT_EQ, s, opt.icl);
	linear(this, m.col(i), IRT_EQ, s, opt.icl);
    }
    // Both diagonals must have sum s
    {
      IntVarArgs d1y(n);
      IntVarArgs d2y(n);
      for (int i = n; i--; ) {
	d1y[i] = m(i,i);
	d2y[i] = m(n-i-1,i);
      }
      linear(this, d1y, IRT_EQ, s, opt.icl);
      linear(this, d2y, IRT_EQ, s, opt.icl);
    }

    // All fields must be distinct
    distinct(this, x, opt.icl);

    // Break some (few) symmetries
    rel(this, m(0,0), IRT_GR, m(0,n-1));
    rel(this, m(0,0), IRT_GR, m(n-1,0));

    branch(this, x, BVAR_SIZE_MIN, BVAL_SPLIT_MIN);
  }

  /// Constructor for cloning \a s
  MagicSquare(bool share, MagicSquare& s) : Example(share,s), n(s.n) {
    x.update(this, share, s.x);
  }

  /// Copy during cloning
  virtual Space*
  copy(bool share) {
    return new MagicSquare(share,*this);
  }
  /// Print solution
  virtual void
  print(void) {
    // Matrix-wrapper for the square
    MiniModel::Matrix<IntVarArray> m(x, n, n);
    for (int i = 0; i<n; i++) {
      std::cout << "\t";
      for (int j = 0; j<n; j++) {
	std::cout.width(2);
	std::cout << m(i,j) << "  ";
      }
      std::cout << std::endl;
    }
  }

};

/** \brief Main-function
 *  \relates MagicSquare
 */
int
main(int argc, char** argv) {
  Options opt("MagicSquare");
  opt.iterations = 1;
  opt.size       = 7;
  opt.parse(argc,argv);
  Example::run<MagicSquare,DFS>(opt);
  return 0;
}

// STATISTICS: example-any

