/** Copyright (c) 2007, David Cuadrado <krawek@gmail.com>
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE. 
**/

#ifndef __MISSING_CLASSES_H
#define __MISSING_CLASSES_H

#include <ruby.h>

#include <gecode/kernel.hh>
#include <gecode/int.hh>
#include <gecode/search.hh>
#include <gecode/minimodel.hh>
#include <gecode/set.hh>

#include "vararray.h"

namespace Gecode {

class MBranchingDesc
{
	public:
		MBranchingDesc();
		~MBranchingDesc();
		
		void setPtr(const Gecode::BranchingDesc *);
		const Gecode::BranchingDesc *ptr() const;
		
		int alternatives() const;
		int size() const;
		
	private:
		struct Private;
		Private *const d;
};

class MSpace : public Space
{
	public:
		MSpace();
		explicit MSpace(MSpace& s, bool share=true);
		~MSpace();
		Gecode::Space *copy(bool share);
		
		void own(Gecode::MIntVarArray *iva, const char *name);
		void own(Gecode::MBoolVarArray *bva, const char *name);
		void own(Gecode::MSetVarArray *sva, const char *name);
		
		Gecode::MIntVarArray *intVarArray(const char *name ) const;
		Gecode::MBoolVarArray *boolVarArray(const char *name ) const;
		Gecode::MSetVarArray *setVarArray(const char *name) const;
		
		Gecode::MBranchingDesc *mdescription();
		
		void debug();
		
	private:
		struct Private;
		Private *const d;
};

class MDFS : public Gecode::Search::DFS
{
	public:
		MDFS(MSpace *space, unsigned int c_d, unsigned int a_d, Search::Stop* st = 0);
		~MDFS();
};

namespace Search {
class MStop : public Gecode::Search::Stop
{
	private:
		MStop(int fails, int time);
		
	public:
		MStop();
		~MStop();
		
		bool stop (const Gecode::Search::Statistics &s);
		static Gecode::Search::Stop* create(int fails, int time);
		
		
	private:
		struct Private;
		Private *const d;
};

}


}

#endif


