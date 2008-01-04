/*
 *  Main authors:
 *     Patrick Pekczynski <pekczynski@ps.uni-sb.de>
 *
 *  Copyright:
 *     Patrick Pekczynski, 2005
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
#include "gecode/int/gcc.hh"

static IntSet ds_02(0,2);
static IntSet ds_03(0,3);
static IntSet ds_04(0,4);
static IntSet ds_12(1,2);
static IntSet ds_14(1,4);
static IntSet ds_18(1,8);

class GCCAssignment : public Assignment {
  int problow;
  int probup;
  int cardlow;
  int cardup;
  int xsize;
public:
  GCCAssignment(int xlow, int xup,
		int clow, int cup,
		int xs,
		int n0, const IntSet& d0)
    : Assignment(n0, d0),
      problow(xlow), probup(xup),
      cardlow(clow), cardup(cup),
      xsize(xs) {
    reset();
  }

  void reset(void) {
    done = false;
    IntSet card_dom(cardlow, cardup);
    IntSet var_dom(problow, probup);
    for (int i = xsize; i < n; i++) {
      dsv[i].init(card_dom);
    }
    for (int i = 0; i < xsize; i++ )
      dsv[i].init(var_dom);
  }
  void operator++(void) {
    IntSet card_dom(cardlow, cardup);
    IntSet var_dom(problow, probup);
    int i = n-1;
    while (true) {
      ++dsv[i];
      if (dsv[i]())
	return;
      if (i >= xsize && i < n) {
	dsv[i].init(card_dom);
      } else {
	dsv[i].init(var_dom);
      }
      --i;
      if (i<0) {
	done = true;
	return;
      }
    }
  }
};


class GCC_FC_AllLbUb : public IntTest {
public:
  GCC_FC_AllLbUb(const char* t, IntConLevel icl)
    : IntTest(t, 4, ds_14, false, icl) {}
  virtual bool solution(const Assignment& x) const {
    int n[4];
    for (int i=4; i--; )
      n[i] = 0;
    for (int i=x.size(); i--; )
      n[x[i] - 1]++;
    for (int i=4; i--;)
      if (n[i] > 2)
	return false;
    return true;
  }
  virtual void post(Space* home, IntVarArray& x) {
    gcc(home, x, 0, 2, icl);
  }
};

class GCC_FC_AllTriple : public IntTest {
public:
  GCC_FC_AllTriple(const char* t, IntConLevel icl)
    : IntTest(t, 4, ds_14, false, icl) {}
  virtual bool solution(const Assignment& x) const {
    int n[4];
    for (int i=4; i--; )
      n[i] = 0;
    for (int i=x.size(); i--; )
      n[x[i] - 1]++;
    for (int i=4; i--;)
      if (n[i] > 2)
	return false;
    return true;
  }
  virtual void post(Space* home, IntVarArray& x) {
    IntArgs card(12, 1,0,2, 2,0,2, 3,0,2, 4,0,2);
    gcc(home, x, card, 12, 2, true, 1, 4, icl);
  }
};

class GCC_FC_SomeTriple : public IntTest {
public:
  GCC_FC_SomeTriple(const char* t, IntConLevel icl)
    : IntTest(t, 4, ds_14, false, icl) {}
  virtual bool solution(const Assignment& x) const {
    int n[4];
    for (int i=4; i--; )
      n[i] = 0;
    for (int i=x.size(); i--; )
      n[x[i] - 1]++;
    if (n[0] < 2 || n[1] < 2 ||
	n[2] > 0 || n[3] > 0)
      return false;
    return true;
  }
  virtual void post(Space* home, IntVarArray& x) {
    IntArgs card(6, 1,0,2, 2,0,2);
    gcc(home, x, card, 6, 0, false, 1, 4, icl);
  }
};

class GCC_FC_AllEqUb : public IntTest {
public:
  GCC_FC_AllEqUb(const char* t, IntConLevel icl)
    : IntTest(t, 4, ds_12, false, icl) {}
  virtual bool solution(const Assignment& x) const {
    int n[2];
    for (int i=2; i--; )
      n[i] = 0;
    for (int i=x.size(); i--; )
      n[x[i] - 1]++;
    if (n[0] != 2 || n[1] != 2)
      return false;
    return true;
  }
  virtual void post(Space* home, IntVarArray& x) {
    gcc(home, x, 2, icl);
  }
};


class GCC_FC_Shared_AllLbUb : public IntTest {
public:
  GCC_FC_Shared_AllLbUb(const char* t, IntConLevel icl)
    : IntTest(t,2,ds_14,false, icl) {}
  virtual bool solution(const Assignment& x) const {
    if (x[0] != x[1]) {
      return true;
    } else {
      return false;
    }
  }
  virtual void post(Space* home, IntVarArray& x) {
    IntVarArgs y(6);
    for (int i = 0; i < 6; i++) {
      if (i < 3) {
	y[i] = x[0];
      } else {
	y[i] = x[1];
      }
    }
    gcc(home, y, 0, 3, icl);
  }
};

class GCC_FC_Shared_SomeTrip : public IntTest {
public:
  GCC_FC_Shared_SomeTrip(const char* t, IntConLevel icl)
    : IntTest(t,1,ds_14,false,icl) {}
  virtual bool solution(const Assignment& x) const {
    if (x[0] == 1) {
      return true;
    } else {
      return false;
    }
  }
  virtual void post(Space* home, IntVarArray& x) {
    IntArgs c(3, 1,4,4);

    IntVarArgs y(4);
    for (int i = 0; i < 4; i++) {
      y[i] = x[0];
    }
    gcc(home, y, c, 3, 0, false, 1, 4, icl);
  }
};


class GCC_VC_AllLbUb : public IntTest {
private:
  static const int lb = 0;
  static const int rb = 2;

  static const int xs = 7;
  static const int ve = 4;

  static const int minocc = 0;
  static const int maxocc = 2;


  Assignment* make_assignment() {
    return new GCCAssignment(lb, rb, minocc, maxocc, ve, xs, dom);
  }


public:
  GCC_VC_AllLbUb(const char* t, IntConLevel icl)
    : IntTest(t, xs, ds_02, false,icl) {}
  virtual bool solution(const Assignment& x) const {
//     std::cout << "GCC-Sol: ";
//     for (int i = 0; i < xs; i++) {
//       if (i == ve) std::cout << "||";
//       std::cout << x[i] << " ";
//     }
//     std::cout << "...";

    for (int i = 0; i < ve; i++) {
      if ( x[i] < lb || x[i] > rb) {
// 	std::cout << "wrong bounds\n";
	return false;
      }
    }

    GECODE_AUTOARRAY(int, count, xs - ve);
    for (int i = ve; i < xs; i++) {
      count[i - ve] = 0;
      if (x[i] < minocc || x[i] > maxocc) {
// 	std::cout << "min-max-occ\n";
	return false;
      }
    }

    for (int i = 0; i < ve; i++) {
      count[x[i]]++;
    }

    for (int i = 0; i < xs - ve; i++) {
      if (count[i] != x[i + ve]) {
// 	std::cout << "counting failed\n";
	return false;
      }
    }

//     std::cout << "valid\n";
    return true;
  }

  virtual void post(Space* home, IntVarArray& x) {
    // std::cout << "test_post\n";

    // get the number of used values
    GECODE_AUTOARRAY(bool, done, xs - ve);
    for (int i = 0; i < xs - ve; i++) {
      done[i] = false;
    }

//     int nov = 0;
//     for (int i = 0; i < xs - ve; i++) {
//       for (int j = 0; j < ve; j++) {
// 	if (x[j].in(i) && !done[i]) {
// 	  nov++;
// 	  done[i] = true;
// 	}
//       }
//     }

//     std::cout << "nov = "<<nov<<"\n";
//     for (int i = ve; i < ve + nov; i++) {
    IntVarArgs y(xs - ve);
    for (int i = ve; i < xs; i++) {
      y[i - ve] = x[i];
//       rel(home, y[i - ve], IRT_LQ, maxocc);
//       rel(home, y[i - ve], IRT_GQ, minocc);
    }

    IntVarArgs z(ve);
    for (int i = 0; i < ve; i++) {
//       std::cout << x[i] << " ";
      z[i] = x[i];
    }
//     std::cout <<"\n";
//     gcc(home, z, c, 12, 2, icl);
    gcc(home, z, y, 0, 2, icl);
  }
};


class GCC_VC_AllTriple : public IntTest {
private:
  static const int lb = 0;
  static const int rb = 2;

  static const int xs = 7;
  static const int ve = 4;

  static const int minocc = 0;
  static const int maxocc = 2;

  Assignment* make_assignment() {
    return new GCCAssignment(lb, rb, minocc, maxocc, ve, xs, dom);
  }


public:
  GCC_VC_AllTriple(const char* t, IntConLevel icl)
    : IntTest(t, xs, ds_02, false,icl) {}
  virtual bool solution(const Assignment& x) const {
//     std::cout << "GCC-Sol: ";
//     for (int i = 0; i < xs; i++) {
//       if (i == ve) std::cout << "||";
//       std::cout << x[i] << " ";
//     }
//     std::cout << "\n";

    for (int i = 0; i < ve; i++) {
      if ( x[i] < lb || x[i] > rb) {
	// std::cout << "wrong bounds\n";
	return false;
      }
    }

    GECODE_AUTOARRAY(int, count, xs - ve);
    for (int i = ve; i < xs; i++) {
      count[i - ve] = 0;
      if (x[i] < minocc || x[i] > maxocc) {
	// std::cout << "min-max-occ\n";
	return false;
      }
    }

    for (int i = 0; i < ve; i++) {
      count[x[i]]++;
    }

    // std::cout << "count: ";
    for (int i = 0; i < xs - ve; i++) {
      // std::cout << count[i] << " ";
    }
    // std::cout << "\n";

    for (int i = 0; i < xs - ve; i++) {
      // std::cout << "comp: "<< count[i] <<" & "<<x[i + ve] << "\n";
      if (count[i] != x[i + ve]) {
	// std::cout << "count not met\n";
	return false;
      }
    }

    // std::cout << "valid\n";
    return true;
  }

  virtual void post(Space* home, IntVarArray& x) {
    // std::cout << "test_post\n";

    // get the number of used values
    GECODE_AUTOARRAY(bool, done, xs - ve);
    for (int i = 0; i < xs - ve; i++) {
      done[i] = false;
    }

    IntVarArgs y(xs - ve);
    for (int i = ve; i < xs; i++) {
      y[i - ve] = x[i];
      rel(home, y[i - ve], IRT_LQ, maxocc);
      rel(home, y[i - ve], IRT_GQ, minocc);
    }

    IntVarArgs z(ve);
    for (int i = 0; i < ve; i++) {
      z[i] = x[i];
    }

    IntArgs value(3, 0, 1, 2);
//     std::cout <<"\n";
//     gcc(home, z, c, 12, 2, icl);
    gcc(home, z, value, y, 3, 2, true, 0,2,  icl);
  }
};


class GCC_VC_SomeTriple : public IntTest {
private:
  static const int lb = 0;
  static const int rb = 2;

  static const int xs = 6;
  static const int ve = 4;

  static const int minocc = 0;
  static const int maxocc = 2;

  Assignment* make_assignment() {
    return new GCCAssignment(lb, rb, minocc, maxocc, ve, xs, dom);
  }

public:
  GCC_VC_SomeTriple(const char* t, IntConLevel icl)
    : IntTest(t, xs, ds_02, false,icl) {}
  virtual bool solution(const Assignment& x) const {
//     std::cout << "GCC-Sol: ";
//     for (int i = 0; i < xs; i++) {
//       if (i == ve) std::cout << "||";
//       std::cout << x[i] << " ";
//     }
//     std::cout << "\n";

    for (int i = 0; i < ve; i++) {
      if ( x[i] < lb || x[i] > rb) {
// 	std::cout << "wrong bounds\n";
	return false;
      }
    }

    GECODE_AUTOARRAY(int, count, xs - ve);
    for (int i = ve; i < xs; i++) {
      count[i - ve] = 0;
      if (x[i] < minocc || x[i] > maxocc) {
// 	std::cout << "min-max-occ\n";
	return false;
      }
    }

    for (int i = 0; i < ve; i++) {
      if (x[i] == 0) {
	count[0]++;
      }
      if (x[i] == 1) {
	count[1]++;
      }
    }

    for (int i = 0; i < ve; i++) {
      if (x[i] == 2) {
// 	std::cout << "2 not allowed!\n";
	return false;
      }
    }
//     std::cout << "\n";

    for (int i = 0; i < xs - ve; i++) {
//       std::cout << "comp: "<< count[i] <<" & "<<x[i + ve] << "\n";
      if (count[i] != x[i + ve]) {
// 	std::cout << "count not met\n";
	return false;
      }
    }

//     std::cout << "valid\n";
    return true;
  }

  virtual void post(Space* home, IntVarArray& x) {

    IntVarArgs y(xs - ve);
    for (int i = ve; i < xs; i++) {
      y[i - ve] = x[i];
      rel(home, y[i - ve], IRT_LQ, maxocc);
      rel(home, y[i - ve], IRT_GQ, minocc);
    }

    IntVarArgs z(ve);
    for (int i = 0; i < ve; i++) {
      z[i] = x[i];
    }

    IntArgs value(2, 0, 1);
    gcc(home, z, value, y, 2, 0, false, 0,2,  icl);
  }
};


class GCC_VC_Shared_SomeTriple : public IntTest {
public:
  GCC_VC_Shared_SomeTriple(const char* t, IntConLevel icl)
    : IntTest(t,3,ds_04,false,icl) {}
  virtual bool solution(const Assignment& x) const {
    if ( (x[0] != 1 && x[0] != 3) ||
	 (x[1] != 1 && x[1] != 3)) {
      return false;
    }
    if (x[0] == x[1]) {
      return false;
    }
    if (x[0] < 1 || x[1] < 1) {
      return false;
    }
    if (x[2] != 3) {
      return false;
    }
    return true;
  }
  virtual void post(Space* home, IntVarArray& x) {
    IntVarArgs y(6);
    for (int i = 0; i < 6; i++) {
      if (i < 3) {
	y[i] = x[0];
      } else {
	y[i] = x[1];
      }
      rel(home, y[i], IRT_GQ, 1);
    }
    IntArgs value(2, 1, 3);
    IntVarArgs z(2);
    z[0] = x[2];
    z[1] = x[2];
    rel(home, z[0], IRT_EQ, 3);
    rel(home, z[1], IRT_EQ, 3);

    gcc(home, y, value, z, 2, 0, false, 1, 4, icl);
  }
};





// Testing with Fixed Cardinalities
// FixCard::\(\(Shared::\)*\(All\|Some\)::\([lubv,()]+\)\)::\(Bnd\|Dom\|Val\)
// VarCard::\(\(Shared::\)*\(All\|Some\)::\([lubv,()]+\)\)::\(Bnd\|Dom\|Val\)

GCC_FC_AllLbUb _gccbnd_all("GCC::FixCard::Bnd::All::(lb,ub)",ICL_BND);
GCC_FC_AllLbUb _gccdom_all("GCC::FixCard::Dom::All::(lb,ub)",ICL_DOM);
GCC_FC_AllLbUb _gccval_all("GCC::FixCard::Val::All::(lb,ub)",ICL_VAL);

GCC_FC_AllEqUb _gccbnd_alleq("GCC::FixCard::Bnd::All::ub",ICL_BND);
GCC_FC_AllEqUb _gccdom_alleq("GCC::FixCard::Dom::All::ub",ICL_DOM);
GCC_FC_AllEqUb _gccval_alleq("GCC::FixCard::Val::All::ub",ICL_VAL);

GCC_FC_AllTriple _gccbnd_alltrip("GCC::FixCard::Bnd::All::(v,lb,ub)",ICL_BND);
GCC_FC_AllTriple _gccdom_alltrip("GCC::FixCard::Dom::All::(v,lb,ub)",ICL_DOM);
GCC_FC_AllTriple _gccval_alltrip("GCC::FixCard::Val::All::(v,lb,ub)",ICL_VAL);

GCC_FC_SomeTriple _gccbnd_sometrip("GCC::FixCard::Bnd::Some::(v,lb,ub)",ICL_BND);
GCC_FC_SomeTriple _gccdom_sometrip("GCC::FixCard::Dom::Some::(v,lb,ub)",ICL_DOM);
GCC_FC_SomeTriple _gccval_sometrip("GCC::FixCard::Val::Some::(v,lb,ub)",ICL_VAL);


// GCC_FC_Shared_AllLbUb _gccbnd_shared_all("GCC::FixCard::Bnd::Shared::All::(lb,ub)",ICL_BND);
// GCC_FC_Shared_AllLbUb _gccdom_shared_all("GCC::FixCard::Dom::Shared::All::(lb,ub)",ICL_DOM);
// GCC_FC_Shared_AllLbUb _gccval_shared_all("GCC::FixCard::Val::Shared::All::(lb,ub)",ICL_VAL);

// GCC_FC_Shared_SomeTrip _gccbnd_shared_tripsome("GCC::FixCard::Bnd::Shared::Some::(v,lb,ub)",ICL_BND);
// GCC_FC_Shared_SomeTrip _gccdom_shared_tripsome("GCC::FixCard::Dom::Shared::Some::(v,lb,ub)",ICL_DOM);
// GCC_FC_Shared_SomeTrip _gccval_shared_tripsome("GCC::FixCard::Val::Shared::Some::(v,lb,ub)",ICL_VAL);

// Testing with Cardinality Variables

GCC_VC_AllLbUb _gccbnd_all_var("GCC::VarCard::Bnd::All::(lb,ub)",ICL_BND);
GCC_VC_AllLbUb _gccdom_all_var("GCC::VarCard::Dom::All::(lb,ub)",ICL_DOM);
GCC_VC_AllLbUb _gccval_all_var("GCC::VarCard::Val::All::(lb,ub)",ICL_VAL);

GCC_VC_AllTriple _gccbnd_alltrip_var("GCC::VarCard::Bnd::All::(v,lb,ub)",ICL_BND);
GCC_VC_AllTriple _gccdom_alltrip_var("GCC::VarCard::Dom::All::(v,lb,ub)",ICL_DOM);
GCC_VC_AllTriple _gccval_alltrip_var("GCC::VarCard::Val::All::(v,lb,ub)",ICL_VAL);

GCC_VC_SomeTriple _gccbnd_sometrip__var("GCC::VarCard::Bnd::Some::(v,lb,ub)",ICL_BND);
GCC_VC_SomeTriple _gccdom_sometrip__var("GCC::VarCard::Dom::Some::(v,lb,ub)",ICL_DOM);
GCC_VC_SomeTriple _gccval_sometrip__var("GCC::VarCard::Val::Some::(v,lb,ub)",ICL_VAL);

GCC_VC_Shared_SomeTriple _gccbnd_shared_sometrip_var("GCC::VarCard::Bnd::Shared::Some::(lb,ub)",ICL_BND);
GCC_VC_Shared_SomeTriple _gccdom_shared_sometrip_var("GCC::VarCard::Dom::Shared::Some::(lb,ub)", ICL_DOM);
GCC_VC_Shared_SomeTriple _gccval_shared_sometrip_var("GCC::VarCard::Val::Shared::Some::(lb,ub)", ICL_VAL);



// STATISTICS: test-int

