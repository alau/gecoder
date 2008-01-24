/*
 *  Main authors:
 *     Christian Schulte <schulte@gecode.org>
 *     Guido Tack <tack@gecode.org>
 *
 *  Copyright:
 *     Christian Schulte, 2002
 *     Guido Tack, 2004
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

#ifndef __GECODE_SUPPORT_PQUEUE_HH__
#define __GECODE_SUPPORT_PQUEUE_HH__

#include "gecode/kernel.hh"

#include <cassert>
#include <algorithm>

/*
 * The shared queue
 *
 */

namespace Gecode { namespace Support {

  /**
   * \brief Simple fixed-size priority queue
   *
   * The order is implemented by an instance of the class \a Less which
   * must provide the single member function
   * \code bool operator()(const T&, const T&) \endcode
   * for comparing elements.
   *
   * Requires \code #include "gecode/support/static-pqueue.hh" \endcode
   * \ingroup FuncSupport
   */
  template <class T, class Less>
  class PQueue  {
  private:
    /// The class holding the shared queue (organized as heap)
    class SharedPQueue  {
    public:
      /// Number of elements currently in queue
      int n;
      /// Maximal size
      int size;
      /// How many references to shared queue exist
      unsigned int ref;
      /// Order used for elements
      Less l;
      /// Elements (will be most likely more than one)
      T pq[1];

      /// Allocate queue with \a n elements
      static SharedPQueue* allocate(int n, const Less& l);
      /// Reorganize after smallest element has changed
      void fixdown(void);
      /// Reorganize after element at position \a n has changed
      void fixup(int n);
    };
    /// Handle to shared queue
    SharedPQueue* spq;

  public:
    /// Default constructor (creates empty queue)
    PQueue(void);
    /// Create for \a n elements and order \a l
    PQueue(int n, const Less& l);
    /// Initialize for \a n elements and order \a l
    void init(int, const Less&);
    /// Assign queue from queue \a p (elements are shared)
    PQueue(const PQueue& p);
    /// Assign queue from queue \a p (elements are shared)
    const PQueue& operator=(const PQueue&);
    /// Release queue
    ~PQueue(void);

    /// Test whether queue is empty
    bool empty(void) const;
    /// Insert element \a x according to order
    void insert(const T& x);
    /// Remove smallest element
    void remove(void);
    /// Provide access to smallest element
    T& top(void);
    /// Reorder queue after smallest element has changed (might not be smallest any longer)
    void fix(void);

    /// Update this queue from queue \a p (share elements if \a share is true)
    void update(const PQueue<T,Less>& p, bool share);
  };

  template <class T, class Less>
  forceinline typename PQueue<T,Less>::SharedPQueue*
  PQueue<T,Less>::SharedPQueue::allocate(int n, const Less& l) {
    SharedPQueue* spq
      = reinterpret_cast<SharedPQueue*>
      (Memory::malloc(sizeof(SharedPQueue) + (n-1)*sizeof(T)));
    spq->size = n;
    spq->n    = 0;
    spq->ref  = 1;
    spq->l    = l;
    return spq;
  }

  template <class T, class Less>
  forceinline void
  PQueue<T,Less>::SharedPQueue::fixdown(void) {
    int k = 0;
    while ((k << 1) < n) {
      int j = k << 1;
      if (j < n-1 && l(pq[j],pq[j+1]))
	j++;
      if (!l(pq[k],pq[j]))
	break;
      std::swap(pq[k], pq[j]);
      k = j;
    }
  }

  template <class T, class Less>
  forceinline void
  PQueue<T,Less>::SharedPQueue::fixup(int k) {
    while (k > 0 && l(pq[k >> 1],pq[k])) {
      std::swap(pq[k],pq[k >> 1]);
      k >>= 1;
    }
  }

  template <class T, class Less>
  forceinline
  PQueue<T,Less>::PQueue(void)
    : spq(NULL) {}

  template <class T, class Less>
  forceinline
  PQueue<T,Less>::PQueue(int n, const Less& l)
    : spq(SharedPQueue::allocate(n,l)) {}

  template <class T, class Less>
  forceinline void
  PQueue<T,Less>::init(int n, const Less& l) {
    spq = SharedPQueue::allocate(n,l);
  }

  template <class T, class Less>
  forceinline
  PQueue<T,Less>::PQueue(const PQueue<T,Less>& p)
    : spq(p.spq) {
    if (spq != NULL)
      spq->ref++;
  }

  template <class T, class Less>
  forceinline const PQueue<T,Less>&
  PQueue<T,Less>::operator =(const PQueue<T,Less>& p) {
    if (this != &p) {
      if ((spq != NULL) && (--spq->ref == 0))
	Memory::free(spq);
      spq = p.spq;
      if (spq != NULL)
	spq->ref++;
    }
    return *this;
  }

  template <class T, class Less>
  forceinline void
  PQueue<T,Less>::update(const PQueue<T,Less>& p, bool share) {
    if (share) {
      spq = p.spq;
      if (spq != NULL)
	spq->ref++;
    } else {
      if (p.spq != NULL) {
	spq = allocate(p.spq->n,p.spq->l);
      } else {
	spq = NULL;
      }
    }
  }

  template <class T, class Less>
  forceinline
  PQueue<T,Less>::~PQueue(void) {
    if ((spq != NULL) && (--spq->ref == 0))
      Memory::free(spq);
  }

  template <class T, class Less>
  forceinline bool
  PQueue<T,Less>::empty(void) const {
    return (spq == NULL) || (spq->n == 0);
  }


  template <class T, class Less>
  forceinline void
  PQueue<T,Less>::insert(const T& x) {
    spq->pq[spq->n++] = x;
    spq->fixup(spq->n-1);
  }

  template <class T, class Less>
  forceinline void
  PQueue<T,Less>::remove(void) {
    spq->pq[0] = spq->pq[--spq->n];
    spq->fixdown();
  }

  template <class T, class Less>
  forceinline T&
  PQueue<T,Less>::top(void) {
    return spq->pq[0];
  }

  template <class T, class Less>
  forceinline void
  PQueue<T,Less>::fix(void) {
    spq->fixdown();
  }

}}

#endif

// STATISTICS: support-any
