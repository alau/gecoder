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
 * \brief %Example: %Alpha puzzle
 *
 * Well-known cryptoarithmetic puzzle of unknown origin.
 *
 * \ingroup Example
 *
 */
class Alpha : public Example {
protected:
  /// Alphabet has 26 letters
  static const int n = 26;
  /// Array for letters
  IntVarArray      le;
public:
  /// Actual model
  Alpha(const Options& opt) : le(this,n,1,n) {
    IntVar
      a(le[ 0]), b(le[ 1]), c(le[ 2]), e(le[ 4]), f(le[ 5]),
      g(le[ 6]), h(le[ 7]), i(le[ 8]), j(le[ 9]), k(le[10]),
      l(le[11]), m(le[12]), n(le[13]), o(le[14]), p(le[15]),
      q(le[16]), r(le[17]), s(le[18]), t(le[19]), u(le[20]),
      v(le[21]), w(le[22]), x(le[23]), y(le[24]), z(le[25]);

    post(this, b+a+l+l+e+t       == 45,  opt.icl);
    post(this, c+e+l+l+o         == 43,  opt.icl);
    post(this, c+o+n+c+e+r+t     == 74,  opt.icl);
    post(this, f+l+u+t+e         == 30,  opt.icl);
    post(this, f+u+g+u+e         == 50,  opt.icl);
    post(this, g+l+e+e           == 66,  opt.icl);
    post(this, j+a+z+z           == 58,  opt.icl);
    post(this, l+y+r+e           == 47,  opt.icl);
    post(this, o+b+o+e           == 53,  opt.icl);
    post(this, o+p+e+r+a         == 65,  opt.icl);
    post(this, p+o+l+k+a         == 59,  opt.icl);
    post(this, q+u+a+r+t+e+t     == 50,  opt.icl);
    post(this, s+a+x+o+p+h+o+n+e == 134, opt.icl);
    post(this, s+c+a+l+e         == 51,  opt.icl);
    post(this, s+o+l+o           == 37,  opt.icl);
    post(this, s+o+n+g           == 61,  opt.icl);
    post(this, s+o+p+r+a+n+o     == 82,  opt.icl);
    post(this, t+h+e+m+e         == 72,  opt.icl);
    post(this, v+i+o+l+i+n       == 100, opt.icl);
    post(this, w+a+l+t+z         == 34,  opt.icl);

    distinct(this, le, opt.icl);

    branch(this, le, opt.naive ? BVAR_NONE : BVAR_SIZE_MIN, BVAL_MIN);
  }

  /// Constructor for cloning \a s
  Alpha(bool share, Alpha& s) : Example(share,s) {
    le.update(this, share, s.le);
  }
  /// Copy during cloning
  virtual Space*
  copy(bool share) {
    return new Alpha(share,*this);
  }
  /// Print solution
  virtual void
  print(void) {
    std::cout << "\t";
    for (int i = 0; i < n; i++) {
      std::cout << ((char) (i+'a')) << '=' << le[i] << ((i<n-1)?", ":"\n");
      if ((i+1) % 8 == 0)
	std::cout << std::endl << "\t";
    }
    std::cout << std::endl;
  }
};

/** \brief Main-function
 *  \relates Alpha
 */
int
main(int argc, char** argv) {
  Options opt("Alpha");
  opt.solutions  = 0;
  opt.iterations = 10;
  opt.naive      = true;
  opt.parse(argc,argv);
  Example::run<Alpha,DFS>(opt);
  return 0;
}

// STATISTICS: example-any

