/*
 *  Main authors:
 *     Christian Schulte <schulte@gecode.org>
 *
 *  Copyright:
 *     Christian Schulte, 2002
 *
 *  Last modified:
 *     $Date: 2006-08-04 16:05:34 +0200 (Fri, 04 Aug 2006) $ by $Author: schulte $
 *     $Revision: 3514 $
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

#ifndef __GECODE_SUPPORT_DYNAMICARRAY_HH__
#define __GECODE_SUPPORT_DYNAMICARRAY_HH__

#include "gecode/kernel.hh"

#include <algorithm>
#include <cassert>

namespace Gecode { namespace Support {

  /**
   * \brief Array with arbitrary number of elements
   *
   * Requires \code #include "gecode/support/dynamic-array.hh" \endcode
   * \ingroup FuncSupport
   */
  template <class T>
  class DynamicArray {
  private:
    /// Size of array
    int n;
    /// Array elements
    T*  x;
    /// Resize to at least \a n + 1 elements
    void resize(int n);
  public:
    /// Initialize with size \a m
    DynamicArray(int m = 32);
    /// Copy elements from array \a a
    DynamicArray(const DynamicArray<T>& a);
    /// Release memory
    ~DynamicArray(void);

    /// Assign array (copy elements from \a a)
    const DynamicArray<T>& operator =(const DynamicArray<T>& a);

    /// Return element at position \a i (possibly resize)
    T& operator[](int i);
    /// Return element at position \a i
    const T& operator [](int) const;

    /// Cast in to pointer of type \a T
    operator T*(void);
  };


  template <class T>
  forceinline
  DynamicArray<T>::DynamicArray(int m)
    : n(m), x(Memory::bmalloc<T>(n)) {}

  template <class T>
  forceinline
  DynamicArray<T>::DynamicArray(const DynamicArray<T>& a)
    : n(a.n), x(Memory::bmalloc<T>(n)) {
    (void) Memory::bcopy<T>(x,a.x,n);
  }

  template <class T>
  forceinline
  DynamicArray<T>::~DynamicArray(void) {
    Memory::free(x);
  }

  template <class T>
  forceinline const DynamicArray<T>&
  DynamicArray<T>::operator =(const DynamicArray<T>& a) {
    if (this != &a) {
      if (n < a.n) {
	Memory::free(x); n = a.n; x = Memory::bmalloc<T>(n);
      }
      (void) Memory::bcopy(x,a.x,n);
    }
    return *this;
  }

  template <class T>
  void
  DynamicArray<T>::resize(int i) {
    int m = std::max(i+1, (3*n)/2);
    x = Memory::brealloc(x,n,m);
    n = m;
  }

  template <class T>
  forceinline T&
  DynamicArray<T>::operator [](int i) {
    if (i >= n) resize(i);
    assert(n > i);
    return x[i];
  }

  template <class T>
  forceinline const T&
  DynamicArray<T>::operator [](int i) const {
    assert(n > i);
    return x[i];
  }

  template <class T>
  forceinline
  DynamicArray<T>::operator T*(void) {
    return x;
  }

}}

#endif

// STATISTICS: support-any
