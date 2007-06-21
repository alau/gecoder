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

#ifndef _VARARRAY_H
#define _VARARRAT_H

#include <gecode/int.hh>
#include <gecode/set.hh>


namespace Gecode {

class MVarArray
{
	public:
		MVarArray();
		virtual ~MVarArray();
		virtual void enlargeArray(Gecode::Space *parent, int n = 1) = 0;
		
		int count() const;
		int size() const;
		
		void setCount(int c);
		void setSize(int n);
		
	private:
		struct Private;
		Private *const d;
};

class MIntVarArray : public MVarArray
{
	public:
		MIntVarArray();
		MIntVarArray(const Gecode::IntVarArray &arr);
		MIntVarArray(Space *home, int n);
		MIntVarArray(Space *home, int n, int min, int max);
		MIntVarArray(Space *home, int n, const IntSet &s);
		
		~MIntVarArray();
		
		void enlargeArray(Gecode::Space *parent, int n = 1);
		
		void setArray(const Gecode::IntVarArray &arr);
		Gecode::IntVarArray *ptr() const;
		
		Gecode::IntVar &at(int index);
		void push(const Gecode::IntVar& intvar);
		
		void debug() const;
		
		IntVar &operator [](int index);
		
	private:
		struct Private;
		Private *const d;
};

class MBoolVarArray : public MVarArray
{
	public:
		MBoolVarArray();
		MBoolVarArray(const Gecode::BoolVarArray &arr);
		MBoolVarArray(Space *home, int n);

		~MBoolVarArray();
		
		void enlargeArray(Gecode::Space *parent, int n = 1);
		
		void setArray(const Gecode::BoolVarArray &arr);
		Gecode::BoolVarArray *ptr() const;
		
		Gecode::BoolVar &at(int index);
		Gecode::BoolVar &operator[](int index);
		
		void push(const Gecode::BoolVar& intvar);
		
		void debug() const;
		
	private:
		struct Private;
		Private *const d;
};



class MSetVarArray : public MVarArray
{
	public:
		MSetVarArray();
		MSetVarArray(const Gecode::SetVarArray &arr);
		
		MSetVarArray(Space *home, int n);
		MSetVarArray(Space *home, int n, int glbMin, int glbMax, int lubMin, int lubMax, unsigned int minCard=0, unsigned int maxCard=Limits::Set::card_max);
		
		MSetVarArray(Space *home, int n, const IntSet &glb, int lubMin, int lubMax, unsigned int minCard=0, unsigned int maxCard=Limits::Set::card_max);
		
		MSetVarArray(Space *home, int n, int glbMin, int glbMax, const IntSet &lub, unsigned int minCard=0, unsigned int maxCard=Limits::Set::card_max);
		
		MSetVarArray(Space *home, int n, const IntSet &glb, const IntSet &lub, unsigned int minCard=0, unsigned int maxCard=Limits::Set::card_max);
		
		~MSetVarArray();
		
		
		
		void enlargeArray(Gecode::Space *parent, int n = 1);
		
		void setArray(const Gecode::SetVarArray &arr);
		Gecode::SetVarArray *ptr() const;
		
		Gecode::SetVar &at(int index);
		Gecode::SetVar &operator[](int index);
		
		void debug() const;
		
	private:
		struct Private;
		Private *const d;
};

}


#endif

