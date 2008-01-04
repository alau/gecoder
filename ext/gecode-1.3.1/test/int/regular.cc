/*
 *  Main authors:
 *     Christian Schulte <schulte@gecode.org>
 *
 *  Copyright:
 *     Christian Schulte, 2005
 *
 *  Last modified:
 *     $Date: 2006-08-04 16:07:12 +0200 (Fri, 04 Aug 2006) $ by $Author: schulte $
 *     $Revision: 3518 $
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

#include "test/int.hh"
#include "test/log.hh"

static IntSet ds_22(-2,2);

class RegularA : public IntTest {
public:
  RegularA(const char* t)
    : IntTest(t,4,ds_22,false,ICL_DOM) {}
  virtual bool solution(const Assignment& x) const {
    return (((x[0] == 0) || (x[0] == 2)) &&
	    ((x[1] == -1) || (x[1] == 1)) &&
	    ((x[2] == 0) || (x[2] == 1)) &&
	    ((x[3] == 0) || (x[3] == 1)));
  }
  virtual void post(Space* home, IntVarArray& x) {
    REG r =
      (REG(0) | REG(2)) +
      (REG(-1) | REG(1)) +
      (REG(7) | REG(0) | REG(1)) +
      (REG(0) | REG(1));
    DFA d(r);
    regular(home, x, d);
  }
};

class RegularB : public IntTest {
public:
  RegularB(const char* t)
    : IntTest(t,4,ds_22,false,ICL_DOM) {}
  virtual bool solution(const Assignment& x) const {
    return (x[0]<x[1]) && (x[1]<x[2]) && (x[2]<x[3]);
  }
  virtual void post(Space* home, IntVarArray& x) {
    REG r =
      (REG(-2) + REG(-1) + REG(0) + REG(1)) |
      (REG(-2) + REG(-1) + REG(0) + REG(2)) |
      (REG(-2) + REG(-1) + REG(1) + REG(2)) |
      (REG(-2) + REG(0) + REG(1) + REG(2)) |
      (REG(-1) + REG(0) + REG(1) + REG(2));
    DFA d(r);
    regular(home, x, d);
  }
};

class RegularShared : public IntTest {
public:
  RegularShared(const char* t)
    : IntTest(t,2,ds_22,false,ICL_DOM) {}
  virtual bool solution(const Assignment& x) const {
    return (((x[0] == 0) || (x[0] == 2)) &&
	    ((x[1] == -1) || (x[1] == 1)) &&
	    ((x[0] == 0) || (x[0] == 1)) &&
	    ((x[1] == 0) || (x[1] == 1)));
  }
  virtual void post(Space* home, IntVarArray& x) {
    Log::log("post regular: x[0]x[1]x[0]x[1] in (0|2)(-1|1)(7|0|1)(0|1)",
	     "\tREG r = \n"
	     "\t  (REG(0) | REG(2)) +\n"
	     "\t  (REG(-1) | REG(1)) +\n"
	     "\t  (REG(7) | REG(0) | REG(1)) +\n"
	     "\t  (REG(0) | REG(1));\n"
	     "\tDFA d(r);\n"
	     "\tIntVarArgs y(4);\n"
	     "\ty[0]=x[0]; y[1]=x[1]; y[2]=x[0]; y[3]=x[1];\n"
	     "\tregular(home, y, d);\n");
    REG r =
      (REG(0) | REG(2)) +
      (REG(-1) | REG(1)) +
      (REG(7) | REG(0) | REG(1)) +
      (REG(0) | REG(1));
    DFA d(r);
    IntVarArgs y(4);
    y[0]=x[0]; y[1]=x[1]; y[2]=x[0]; y[3]=x[1];
    regular(home, y, d);
  }
};

RegularA _rega("Regular::A");
RegularB _regb("Regular::B");
RegularShared _regsa("Regular::Shared");

// STATISTICS: test-int

