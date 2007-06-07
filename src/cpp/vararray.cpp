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

#include "vararray.h"

namespace Gecode {


struct MVarArray::Private
{
	int count;
	int size;
};

MVarArray::MVarArray() : d(new Private)
{
}

MVarArray::~MVarArray()
{
	delete d;
}

int MVarArray::count() const
{
	return d->count;
}

int MVarArray::size() const
{
	return d->size;
}

void MVarArray::setCount(int c)
{
	d->count = c;
}

void MVarArray::setSize(int n)
{
	d->size = n;
}


// MINTVARARRAY

struct MIntVarArray::Private
{
	Gecode::IntVarArray array;
};


MIntVarArray::MIntVarArray() : d(new Private)
{
	setArray(Gecode::IntVarArray());
}

MIntVarArray::MIntVarArray(const Gecode::IntVarArray &arr) : d(new Private)
{
	setArray(arr);
	setCount(0);
}

MIntVarArray::MIntVarArray (Space *home, int n) : d(new Private)
{
	setArray(Gecode::IntVarArray(home, n));
}

MIntVarArray::MIntVarArray (Space *home, int n, int min, int max) : d(new Private)
{
	setArray(Gecode::IntVarArray(home, n, min, max));
}

MIntVarArray::MIntVarArray (Space *home, int n, const IntSet &s) : d(new Private)
{
	setArray(Gecode::IntVarArray(home, n, s));
}


MIntVarArray::~MIntVarArray()
{
	delete d;
}

void MIntVarArray::setArray(const Gecode::IntVarArray &arr)
{
	d->array = arr;
	setSize(arr.size());
}

void MIntVarArray::enlargeArray(Gecode::Space *parent, int n)
{
	Gecode::IntVarArray na(parent, size()+n, 0, 0);
	for(int i = count(); i--; )
		na[i] = d->array[i];
	
	d->array = na;
	
	setSize(size() + n);
}

Gecode::IntVarArray *MIntVarArray::ptr() const
{
	return &d->array;
}

Gecode::IntVar &MIntVarArray::at(int index)
{
	return d->array[index];
}

IntVar &MIntVarArray::operator [](int index)
{
	return d->array[index];
}

void MIntVarArray::debug() const
{
	for(int i = 0; i < d->array.size(); i++)
	{
		std::cout << d->array[i] << " ";
	}
	std::cout << std::endl;
}


// MBOOLVARARRAY

struct MBoolVarArray::Private
{
	Gecode::BoolVarArray array;
};


MBoolVarArray::MBoolVarArray() : d(new Private)
{
}

MBoolVarArray::MBoolVarArray(const Gecode::BoolVarArray &arr) : d(new Private)
{
	d->array = arr;
	setSize(arr.size());
	setCount(0);
}

MBoolVarArray::~MBoolVarArray()
{
	delete d;
}

void MBoolVarArray::setArray(const Gecode::BoolVarArray &arr)
{
	d->array = arr;
	setSize(arr.size());
}

void MBoolVarArray::enlargeArray(Gecode::Space *parent, int n)
{
	Gecode::BoolVarArray na(parent, size()+n, 0, 0);
	for(int i = count(); i--; )
		na[i] = d->array[i];
	
	d->array = na;
	
	setSize(size() + n);
}

Gecode::BoolVarArray *MBoolVarArray::ptr() const
{
	return &d->array;
}

Gecode::BoolVar &MBoolVarArray::at(int index)
{
	return d->array[index];
}

Gecode::BoolVar &MBoolVarArray::operator[](int index)
{
	return d->array[index];
}

void MBoolVarArray::debug() const
{
	for(int i = 0; i < d->array.size(); i++)
	{
		std::cout << d->array[i] << " ";
	}
	std::cout << std::endl;
}


// SETVARARRAY

struct MSetVarArray::Private
{
	Gecode::SetVarArray array;
};

MSetVarArray::MSetVarArray() : d(new Private)
{
}

MSetVarArray::MSetVarArray(const Gecode::SetVarArray &arr) : d(new Private)
{
	d->array = arr;
	setSize(arr.size());
	setCount(0);
}

MSetVarArray::MSetVarArray(Space *home, int n) : d(new Private)
{
	setArray(Gecode::SetVarArray(home, n));
}

MSetVarArray::MSetVarArray(Gecode::Space *home, int n, int glbMin, int glbMax, int lubMin, int lubMax, unsigned int minCard, unsigned int maxCard) : d(new Private)
{
	setArray(Gecode::SetVarArray(home, n, glbMin, glbMax, lubMin, lubMax, minCard, maxCard));
}
		
MSetVarArray::MSetVarArray(Gecode::Space *home, int n, const Gecode::IntSet &glb, int lubMin, int lubMax, unsigned int minCard, unsigned int maxCard) : d(new Private)
{
	setArray(Gecode::SetVarArray(home, n, glb, lubMin, lubMax, minCard, maxCard));
}

MSetVarArray::MSetVarArray(Gecode::Space *home, int n, int glbMin, int glbMax, const Gecode::IntSet &lub, unsigned int minCard, unsigned int maxCard) : d(new Private)
{
	setArray(Gecode::SetVarArray(home, n, glbMin, glbMax, lub, minCard, maxCard));
}

MSetVarArray::MSetVarArray(Gecode::Space *home, int n, const Gecode::IntSet &glb, const Gecode::IntSet &lub, unsigned int minCard, unsigned int maxCard) : d(new Private)
{
	setArray(Gecode::SetVarArray(home, n, glb, lub, minCard, maxCard));
}

MSetVarArray::~MSetVarArray()
{
	delete d;
}

void MSetVarArray::setArray(const Gecode::SetVarArray &arr)
{
	d->array = arr;
	setSize(arr.size());
}

void MSetVarArray::enlargeArray(Gecode::Space *parent, int n)
{
	Gecode::SetVarArray na(parent, size()*n);
	for (int i = count(); i--; )
		na[i] = d->array[i];
	
	d->array = na;
	
	setSize(size() + n);
}

Gecode::SetVarArray *MSetVarArray::ptr() const
{
	return &d->array;
}

Gecode::SetVar &MSetVarArray::at(int index)
{
	return d->array[index];
}

Gecode::SetVar &MSetVarArray::operator[](int index)
{
	return d->array[index];
}

void MSetVarArray::debug() const
{
	for(int i = 0; i < d->array.size(); i++)
	{
		std::cout << d->array[i] << " ";
	}
	std::cout << std::endl;
}


}







