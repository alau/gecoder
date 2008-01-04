/*
 *  Main authors:
 *     Christian Schulte <schulte@gecode.org>
 *     Mikael Lagerkvist <lagerkvist@gecode.org>
 *
 *  Copyright:
 *     Christian Schulte, 2004
 *     Mikael Lagerkvist, 2005
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

#include "test/test.hh"
#include "test/log.hh"

#ifdef GECODE_HAVE_MTRACE
#include <mcheck.h>
#endif

#include <iostream>

#include <cstdlib>
#include <string>
#include <cstring>
#include <ctime>
#include <vector>
#include <utility>

using std::vector;
using std::make_pair;
using std::pair;

vector<pair<bool, const char*> > testpat;

Test* Test::all = NULL;
Support::RandomGenerator Test::randgen = Support::RandomGenerator();


namespace {

  void report_error(const Options& o, std::string name) {
    std::cout << "Options: -seed " << o.seed;
    if (o.fixprob != o.deffixprob)
      std::cout << "  -fixprob " << o.fixprob;
    if (o.flushprob != o.defflushprob)
      std::cout << "  -flushprob " << o.flushprob;
    std::cout << "  -test " << name << std::endl;
    if (o.log)
      Log::print(o.display);
  }
}

int
main(int argc, char** argv) {
#ifdef GECODE_HAVE_MTRACE
  mtrace();
#endif

  Options o;
  o.parse(argc, argv);
  Test::randgen.seed(o.seed);
  Log::logging(o.log);

  for (Test* t = Test::tests(); t != NULL; t = t->next()) {
    std::string name(t->module()); name += "::"; name += t->test();
    try {
      if (testpat.size() != 0) {
	bool match_found   = false;
	bool some_positive = false;
	for (unsigned int i = 0; i < testpat.size(); ++i) {
	  if (testpat[i].first) { // Negative pattern
	    if (name.find(testpat[i].second) != std::string::npos)
	      goto next;
	  } else {               // Positive pattern
	    some_positive = true;
	    if (name.find(testpat[i].second) != std::string::npos)
	      match_found = true;
	  }
	}
	if (some_positive && !match_found) goto next;
      }
      std::cout << name << ": ";
      std::cout.flush();
      for (int i = o.iter; i--; ) {
	o.seed = Test::randgen.seed();
	if (t->run(o)) {
	  std::cout << "+";
	  std::cout.flush();
	} else {
	  std::cout << "-" << std::endl;
	  report_error(o, name);
	  if(o.stop_on_error) return 1;
	}
      }
    std::cout << std::endl;
    } catch (Gecode::Exception e) {
      std::cout << "Exception in \"Gecode::" << e.what()
		<< "." << std::endl
		<< "Stopping..." << std::endl;
	  report_error(o, name);
	  if(o.stop_on_error) return 1;
    }
  next:;
  }
  return 0;
}

void
Options::parse(int argc, char** argv) {
  using namespace std;
  static const char* bool2str[] =
    { "false", "true" };
  int i = 1;
  const char* e = NULL;
  while (i < argc) {
    if (!strcmp(argv[i],"-help") || !strcmp(argv[i],"--help")) {
      std::cerr << "Options for testing:" << std::endl
		<< "\t-seed (unsigned int|\"time\") default: " <<seed<< std::endl
		<< "\t\tthe seed for the random numbers (an integer),"
		<< std::endl
		<< "\t\tor the word time for a random seed based on the "
		<< "current time" << std::endl
		<< "\t-fixprob (unsigned int) default: " <<fixprob<< std::endl
		<< "\t\t1/fixprob is the probability of fixpoint recalculations"
		<< std::endl
		<< "\t-flushprob (unsigned int) default: " <<flushprob<< std::endl
		<< "\t\t1/flushprob is the probability of flushing the the caches"
		<< std::endl
		<< "\t-iter (unsigned int) default: " <<iter<< std::endl
		<< "\t\tthe number of iterations" << std::endl
		<< "\t-test (string) default: (none)" << std::endl
		<< "\t\tsimple pattern for the tests to run" << std::endl
		<< "\t\tprefixing the pattern by a - negates the pattern"
		<< std::endl
		<< "\t\tmultiple pattern-options may be given" << std::endl
		<< "\t-log (opt \"text\"|\"code\") default: off"
		<< std::endl
		<< "\t\tif given, logging will be printed for failures"
		<< std::endl
		<< "\t\tthe optional argument determines the style of the log"
		<< std::endl
		<< "\t\twith text as the default style"
		<< std::endl
		<< "\t-stop (boolean) default: "
		<< bool2str[stop_on_error] << std::endl
		<< "\t\tstop on first error or continue" << std::endl;
      exit(EXIT_SUCCESS);
    } else if (!strcmp(argv[i],"-seed")) {
      if (++i == argc) goto missing;
      if (!strcmp(argv[i],"time")) {
	seed = static_cast<int>(time(NULL));
      } else {
	seed = atoi(argv[i]);
      }
    } else if (!strcmp(argv[i],"-iter")) {
      if (++i == argc) goto missing;
      iter = atoi(argv[i]);
    } else if (!strcmp(argv[i],"-fixprob")) {
      if (++i == argc) goto missing;
      fixprob = atoi(argv[i]);
    } else if (!strcmp(argv[i],"-flushprob")) {
      if (++i == argc) goto missing;
      flushprob = atoi(argv[i]);
    } else if (!strcmp(argv[i],"-test")) {
      if (++i == argc) goto missing;
      int offset = 0;
      bool negative = false;
      if (argv[i][0] == '-') {
	negative = true;
	offset = 1;
      }
      testpat.push_back(make_pair(negative, argv[i] + offset));
    } else if (!strcmp(argv[i],"-log")) {
      log = true;
      if (i+1 != argc) {
	if(argv[i+1][0] == 't') {
	  display = true; ++i;
	} else if (argv[i+1][0] == 'c') {
	  display = false; ++i;
	}
      }
    } else if (!strcmp(argv[i],"-stop")) {
      if (++i == argc) goto missing;
      if(argv[i][0] == 't') {
	stop_on_error = true;
      } else if (argv[i][0] == 'f') {
	stop_on_error = false;
      }
    } else {
      i++;
      goto error;
    }
    i++;
  }
  return;
 missing:
  e = "missing parameter";
 error:
  std::cerr << "Erroneous argument (" << argv[i-1] << ")" << std::endl
       << e << std::endl;
  exit(EXIT_FAILURE);
}

// STATISTICS: test-core
