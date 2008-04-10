/*
 *  Main authors:
 *     Guido Tack <tack@gecode.org>
 *
 *  Copyright:
 *     Guido Tack, 2006
 *
 *  Last modified:
 *     $Date: 2007-11-26 15:48:52 +0100 (Mon, 26 Nov 2007) $ by $Author: tack $
 *     $Revision: 5437 $
 *
 *  This file is part of Gecode, the generic constraint
 *  development environment:
 *     http://www.gecode.org
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */

#ifndef GECODE_GIST_NODEVISITOR_HH
#define GECODE_GIST_NODEVISITOR_HH

namespace Gecode { namespace Gist {
  
  /// \brief Base class for a visitor that runs a cursor over a tree
  template <class Cursor>
  class NodeVisitor {
  protected:
    /// The cursor
    Cursor c;
  public:
    /// Constructor
    NodeVisitor(Cursor& c0);
    /// Reset the cursor object to \a c0
    void setCursor(Cursor& c0);
    /// Return the cursor
    Cursor& getCursor(void);    
  };
  
  /// \brief Run a cursor over a tree, processing nodes in post-order
  template <class Cursor>
  class PostorderNodeVisitor : public NodeVisitor<Cursor> {
  protected:
    using NodeVisitor<Cursor>::c;
    /// Move the cursor to the left-most leaf
    void moveToLeaf(void);
  public:
    /// Constructor
    PostorderNodeVisitor(Cursor& c);
    /// Move cursor to next node, return true if succeeded
    bool next(void);
  };

  /// \brief Run a cursor over a tree, processing nodes in pre-order
  template <class Cursor>
  class PreorderNodeVisitor : public NodeVisitor<Cursor> {
  protected:
    using NodeVisitor<Cursor>::c;
    /// Move cursor to next node from a leaf
    bool backtrack(void);
  public:
    /// Constructor
    PreorderNodeVisitor(Cursor& c);
    /// Move cursor to the next node, return true if succeeded
    bool next(void);
  };
  
}}

#include "gecode/gist/nodevisitor.icc"

#endif

// STATISTICS: gist-any
