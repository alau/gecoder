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

static inline int
compare(int x, IntRelType r, int y) {
  switch (r) {
  case IRT_EQ: return x == y;
  case IRT_NQ: return x != y;
  case IRT_LQ: return x <= y;
  case IRT_LE: return x < y;
  case IRT_GR: return x > y;
  case IRT_GQ: return x >= y;
  default: ;
  }
  return false;
}

class CountIntInt : public IntTest {
private:
  IntRelType irt;
public:
  CountIntInt(const char* t, IntRelType irt0)
    : IntTest(t,4,ds_22), irt(irt0) {}
  virtual bool solution(const Assignment& x) const {
    int m = 0;
    for (int i=0; i<4; i++)
      if (x[i] == 0)
	m++;
    return compare(m,irt,2);
  }
  virtual void post(Space* home, IntVarArray& x) {
    count(home, x, 0, irt, 2);
  }
};

CountIntInt _ceqii("Count::Eq::IntInt",IRT_EQ);
CountIntInt _cnqii("Count::Nq::IntInt",IRT_NQ);
CountIntInt _clqii("Count::Lq::IntInt",IRT_LQ);
CountIntInt _cleii("Count::Le::IntInt",IRT_LE);
CountIntInt _cgrii("Count::Gr::IntInt",IRT_GR);
CountIntInt _cgqii("Count::Gq::IntInt",IRT_GQ);

class CountIntIntDup : public IntTest {
private:
  IntRelType irt;
public:
  CountIntIntDup(const char* t, IntRelType irt0)
    : IntTest(t,4,ds_22), irt(irt0) {}
  virtual bool solution(const Assignment& x) const {
    int m = 0;
    for (int i=0; i<4; i++)
      if (x[i] == 0)
	m += 2;
    return compare(m,irt,4);
  }
  virtual void post(Space* home, IntVarArray& x) {
    IntVarArgs y(8);
    for (int i=0; i<4; i++) {
      y[i]=x[i]; y[4+i]=x[i];
    }
    count(home, y, 0, irt, 4);
  }
};

CountIntIntDup _ceqiid("Count::Eq::IntInt::Dup",IRT_EQ);
CountIntIntDup _cnqiid("Count::Nq::IntInt::Dup",IRT_NQ);
CountIntIntDup _clqiid("Count::Lq::IntInt::Dup",IRT_LQ);
CountIntIntDup _cleiid("Count::Le::IntInt::Dup",IRT_LE);
CountIntIntDup _cgriid("Count::Gr::IntInt::Dup",IRT_GR);
CountIntIntDup _cgqiid("Count::Gq::IntInt::Dup",IRT_GQ);

class CountIntVar : public IntTest {
private:
  IntRelType irt;
public:
  CountIntVar(const char* t, IntRelType irt0)
    : IntTest(t,5,ds_22), irt(irt0) {}
  virtual bool solution(const Assignment& x) const {
    int m = 0;
    for (int i=0; i<4; i++)
      if (x[i] == 0)
	m++;
    return compare(m,irt,x[4]);
  }
  virtual void post(Space* home, IntVarArray& x) {
    IntVarArgs y(4);
    for (int i=0; i<4; i++)
      y[i]=x[i];
    count(home, y, 0, irt, x[4]);
  }
};

CountIntVar _ceqiv("Count::Eq::IntVar",IRT_EQ);
CountIntVar _cnqiv("Count::Nq::IntVar",IRT_NQ);
CountIntVar _clqiv("Count::Lq::IntVar",IRT_LQ);
CountIntVar _cleiv("Count::Le::IntVar",IRT_LE);
CountIntVar _cgriv("Count::Gr::IntVar",IRT_GR);
CountIntVar _cgqiv("Count::Gq::IntVar",IRT_GQ);


class CountIntVarShared : public IntTest {
private:
  IntRelType irt;
public:
  CountIntVarShared(const char* t, IntRelType irt0)
    : IntTest(t,4,ds_22), irt(irt0) {}
  virtual bool solution(const Assignment& x) const {
    int m = 0;
    for (int i=0; i<4; i++)
      if (x[i] == 0)
	m++;
    return compare(m,irt,x[2]);
  }
  virtual void post(Space* home, IntVarArray& x) {
    if(irt == IRT_LQ)
      Log::log("count(home, x, 0)<=x[2]","\tcount(home, x, 0, IRT_LQ, x[2]);");
    else if(irt == IRT_GQ)
      Log::log("count(home, x, 0)>=x[2]","\tcount(home, x, 0, IRT_GQ, x[2]);");
    count(home, x, 0, irt, x[2]);
  }
};

CountIntVarShared _ceqivs("Count::Eq::IntVarShared",IRT_EQ);
CountIntVarShared _cnqivs("Count::Nq::IntVarShared",IRT_NQ);
CountIntVarShared _clqivs("Count::Lq::IntVarShared",IRT_LQ);
CountIntVarShared _cleivs("Count::Le::IntVarShared",IRT_LE);
CountIntVarShared _cgrivs("Count::Gr::IntVarShared",IRT_GR);
CountIntVarShared _cgqivs("Count::Gq::IntVarShared",IRT_GQ);

class CountVarVar : public IntTest {
private:
  IntRelType irt;
public:
  CountVarVar(const char* t, IntRelType irt0)
    : IntTest(t,5,ds_22), irt(irt0) {}
  virtual bool solution(const Assignment& x) const {
    int m = 0;
    for (int i=0; i<3; i++)
      if (x[i] == x[3])
	m++;
    return compare(m,irt,x[4]);
  }
  virtual void post(Space* home, IntVarArray& x) {
    IntVarArgs y(3);
    for (int i=0; i<3; i++)
      y[i]=x[i];
    count(home, y, x[3], irt, x[4]);
  }
};

CountVarVar _ceqvv("Count::Eq::VarVar",IRT_EQ);
CountVarVar _cnqvv("Count::Nq::VarVar",IRT_NQ);
CountVarVar _clqvv("Count::Lq::VarVar",IRT_LQ);
CountVarVar _clevv("Count::Le::VarVar",IRT_LE);
CountVarVar _cgrvv("Count::Gr::VarVar",IRT_GR);
CountVarVar _cgqvv("Count::Gq::VarVar",IRT_GQ);

class CountVarVarSharedA : public IntTest {
private:
  IntRelType irt;
public:
  CountVarVarSharedA(const char* t, IntRelType irt0)
    : IntTest(t,5,ds_22), irt(irt0) {}
  virtual bool solution(const Assignment& x) const {
    int m = 0;
    for (int i=0; i<4; i++)
      if (x[i] == x[1])
	m++;
    return compare(m,irt,x[4]);
  }
  virtual void post(Space* home, IntVarArray& x) {
    IntVarArgs y(4);
    for (int i=0; i<4; i++)
      y[i]=x[i];
    count(home, y, x[1], irt, x[4]);
  }
};

CountVarVarSharedA _ceqvvsa("Count::Eq::VarVarShared::A",IRT_EQ);
CountVarVarSharedA _cnqvvsa("Count::Nq::VarVarShared::A",IRT_NQ);
CountVarVarSharedA _clqvvsa("Count::Lq::VarVarShared::A",IRT_LQ);
CountVarVarSharedA _clevvsa("Count::Le::VarVarShared::A",IRT_LE);
CountVarVarSharedA _cgrvvsa("Count::Gr::VarVarShared::A",IRT_GR);
CountVarVarSharedA _cgqvvsa("Count::Gq::VarVarShared::A",IRT_GQ);

class CountVarVarSharedB : public IntTest {
private:
  IntRelType irt;
public:
  CountVarVarSharedB(const char* t, IntRelType irt0)
    : IntTest(t,5,ds_22), irt(irt0) {}
  virtual bool solution(const Assignment& x) const {
    int m = 0;
    for (int i=0; i<4; i++)
      if (x[i] == x[4])
	m++;
    return compare(m,irt,x[3]);
  }
  virtual void post(Space* home, IntVarArray& x) {
    IntVarArgs y(4);
    for (int i=0; i<4; i++)
      y[i]=x[i];
    count(home, y, x[4], irt, x[3]);
  }
};

CountVarVarSharedB _ceqvvsb("Count::Eq::VarVarShared::B",IRT_EQ);
CountVarVarSharedB _cnqvvsb("Count::Nq::VarVarShared::B",IRT_NQ);
CountVarVarSharedB _clqvvsb("Count::Lq::VarVarShared::B",IRT_LQ);
CountVarVarSharedB _clevvsb("Count::Le::VarVarShared::B",IRT_LE);
CountVarVarSharedB _cgrvvsb("Count::Gr::VarVarShared::B",IRT_GR);
CountVarVarSharedB _cgqvvsb("Count::Gq::VarVarShared::B",IRT_GQ);

class CountVarVarSharedC : public IntTest {
private:
  IntRelType irt;
public:
  CountVarVarSharedC(const char* t, IntRelType irt0)
    : IntTest(t,4,ds_22), irt(irt0) {}
  virtual bool solution(const Assignment& x) const {
    int m = 0;
    for (int i=0; i<4; i++)
      if (x[i] == x[1])
	m++;
    return compare(m,irt,x[3]);
  }
  virtual void post(Space* home, IntVarArray& x) {
    count(home, x, x[1], irt, x[3]);
  }
};

CountVarVarSharedC _ceqvvsc("Count::Eq::VarVarShared::C",IRT_EQ);
CountVarVarSharedC _cnqvvsc("Count::Nq::VarVarShared::C",IRT_NQ);
CountVarVarSharedC _clqvvsc("Count::Lq::VarVarShared::C",IRT_LQ);
CountVarVarSharedC _clevvsc("Count::Le::VarVarShared::C",IRT_LE);
CountVarVarSharedC _cgrvvsc("Count::Gr::VarVarShared::C",IRT_GR);
CountVarVarSharedC _cgqvvsc("Count::Gq::VarVarShared::C",IRT_GQ);


// STATISTICS: test-int

