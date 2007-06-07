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

#include "missing.h"

#include <iostream>
#include <map>

namespace Gecode {

struct MBranchingDesc::Private
{
	const Gecode::BranchingDesc *ptr;
};

MBranchingDesc::MBranchingDesc() : d(new Private)
{

}

MBranchingDesc::~MBranchingDesc()
{
	delete d;
}

void MBranchingDesc::setPtr(const Gecode::BranchingDesc *desc)
{
	d->ptr = desc;
}

const Gecode::BranchingDesc *MBranchingDesc::ptr() const
{
	return d->ptr;
}

int MBranchingDesc::alternatives() const
{
	if(d->ptr) return d->ptr->alternatives();
	
	return -1;
}

int MBranchingDesc::size() const
{
	if(d->ptr) return d->ptr->size();
	
	return -1;
}


///////////////////////////////////// 

struct ltstr
{
	bool operator()(const char* s1, const char* s2) const
	{
		return strcmp(s1, s2) < 0;
	}
};

typedef std::map<const char *, MIntVarArray *, ltstr> IntVarArrays;
typedef std::map<const char *, MBoolVarArray *, ltstr> BoolVarArrays;
typedef std::map<const char *, MSetVarArray *, ltstr> SetVarArrays;

struct MSpace::Private
{
	Private()
	{
		description = new MBranchingDesc;;
	}
	
	~Private()
	{
// 		{
// 			IntVarArrays::iterator it, eend = intArrays.end();
// 			
// 			for(it = intArrays.begin(); it != eend; it++)
// 			{
// 				delete (*it).second;
// 			}
// 		}
// 		{
// 			SetVarArrays::iterator it, eend = setArrays.end();
// 			
// 			for(it = setArrays.begin(); it != eend; it++)
// 			{
// 				delete (*it).second;
// 			}
// 		}
// 		
// 		{
// 			BoolVarArrays::iterator it, eend = boolArrays.end();
// 			
// 			for(it = boolArrays.begin(); it != eend; it++)
// 			{
// 				delete (*it).second;
// 			}
// 		}
		
		delete description;
	}
	
	IntVarArrays intArrays;
	BoolVarArrays boolArrays;
	SetVarArrays setArrays;
	
	MBranchingDesc *description;
};

MSpace::MSpace() : d(new Private())
{
}

MSpace::MSpace(MSpace& s, bool share) : Gecode::Space(share, s), d(new Private)
{
	{
		IntVarArrays::iterator it, eend = s.d->intArrays.end();
		
		for(it = s.d->intArrays.begin(); it != eend; it++)
		{
			Gecode::MIntVarArray *iva = new Gecode::MIntVarArray(this, (*it).second->ptr()->size());
			
			iva->ptr()->update(this, share, *(*it).second->ptr() );
			
			own(iva, (*it).first);
		}
	}
	{
		BoolVarArrays::iterator it, eend = s.d->boolArrays.end();
		
		for(it = s.d->boolArrays.begin(); it != eend; it++)
		{
			Gecode::MBoolVarArray *bva = new Gecode::MBoolVarArray;
			
			bva->ptr()->update(this, share, *(*it).second->ptr() );
			
			own(bva, (*it).first);
		}
	}
	{
		SetVarArrays::iterator it, eend = s.d->setArrays.end();
		
		for(it = s.d->setArrays.begin(); it != eend; it++)
		{
			Gecode::MSetVarArray *sva = new Gecode::MSetVarArray;
			sva->ptr()->update(this, share, *(*it).second->ptr() );
			
			own(sva, (*it).first);
		}
	}
}



MSpace::~MSpace()
{
	delete d;
}

Gecode::Space *MSpace::copy(bool share)
{
	return new MSpace(*this,share);
}

void MSpace::own(Gecode::MIntVarArray *iva, const char *name)
{
	d->intArrays[name] = iva;
}

void MSpace::own(Gecode::MBoolVarArray *bva, const char *name)
{
	d->boolArrays[name] = bva;
}

void MSpace::own(Gecode::MSetVarArray *sva, const char *name)
{
	d->setArrays[name] = sva;
}

Gecode::MIntVarArray *MSpace::intVarArray(const char *name) const
{
	if ( d->intArrays.find(name) == d->intArrays.end() ) return 0;
	return d->intArrays[name];
}

Gecode::MBoolVarArray *MSpace::boolVarArray(const char *name ) const
{
	if ( d->boolArrays.find(name) == d->boolArrays.end() ) return 0;
	return d->boolArrays[name];
}

Gecode::MSetVarArray *MSpace::setVarArray(const char *name ) const
{
	if ( d->setArrays.find(name) == d->setArrays.end() ) return 0;
	return d->setArrays[name];
}


Gecode::MBranchingDesc *MSpace::mdescription()
{
	if(!this->failed() || !d->description->ptr() )
	{
		d->description->setPtr(this->description());
	}
	return d->description;
}

void MSpace::debug()
{
	std::cout << "DEBUG: "<< d->intArrays["default"]->ptr()->size() << std::endl;
}


// DFS
MDFS::MDFS(MSpace *space, unsigned int c_d, unsigned int a_d, Search::Stop* st) : Gecode::Search::DFS(space, c_d, a_d, st, sizeof(space))
{
}

MDFS::~MDFS()
{
}


namespace Search {

// Stop

struct MStop::Private
{
	Gecode::Search::TimeStop *ts;
    Gecode::Search::FailStop *fs;
};

MStop::MStop() : d(new Private)
{
	d->ts = 0;
	d->fs = 0;
}

MStop::MStop(int fails, int time) : d(new Private)
{
	d->ts = new Search::TimeStop(time);
	d->fs = new Search::FailStop(fails);
}

MStop::~MStop()
{
}

bool MStop::stop(const Gecode::Search::Statistics &s)
{
	if (!d->fs || d->ts)
		return false;
	return d->fs->stop(s) || d->ts->stop(s);
}

Gecode::Search::Stop* MStop::create(int fails, int time)
{
	if (fails < 0 && time < 0) return 0;
	if (fails < 0) return new Search::TimeStop( time );
	
	if (time  < 0) return new Search::FailStop(fails);
	
	return new MStop(fails, time);
}


}

}



