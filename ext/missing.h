/**
 * Gecode/R, a Ruby interface to Gecode.
 * Copyright (C) 2007 The Gecode/R development team.
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
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
		
		void gc_mark();
		
		void constrain(MSpace* s);
		
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
class MBAB : public Gecode::BAB<MSpace>
{
	public:
		MBAB(MSpace* space, const Search::Options &o);
		~MBAB();
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


