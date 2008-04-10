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

#ifndef GECODE_GIST_NODECURSOR_HH
#define GECODE_GIST_NODECURSOR_HH

#include "gecode/gist/visualnode.hh"

namespace Gecode { namespace Gist {
  
  /// \brief A cursor that can be run over a tree
  template <class Node>
  class NodeCursor {
  private:
    /// The node where the iteration starts
    Node* _startNode;
    /// The current node
    Node* _node;
  public:
    /// Construct cursor, initially set to \a theNode
    NodeCursor(Node* theNode);
    /// Return current node
    Node* node(void);
    
    /// \name Cursor interface
    //@{
    /// Test if the cursor may move to the parent node
    bool mayMoveUpwards(void);
    /// Move cursor to the parent node
    void moveUpwards(void);
    /// Test if cursor may move to the first child node
    bool mayMoveDownwards(void);
    /// Move cursor to the first child node
    void moveDownwards(void);
    /// Test if cursor may move to the first sibling
    bool mayMoveSidewards(void);
    /// Move cursor to the first sibling
    void moveSidewards(void);    
    //@}
  };

  /// \brief A cursor that computes a tree layout for VisualNodes
  class LayoutCursor : public NodeCursor<VisualNode> {
  public:
    /// Constructor
    LayoutCursor(VisualNode* theNode);

    /// \name Cursor interface
    //@{
    /// Test if the cursor may move to the first child node
    bool mayMoveDownwards(void);
    /// Compute layout for current node
    void processCurrentNode(void);
    //@}
  };

  /// \brief A cursor that marks failed subtrees as hidden
  class HideFailedCursor : public NodeCursor<VisualNode> {
  public:
    /// Constructor
    HideFailedCursor(VisualNode* theNode);
    /// \name Cursor interface
    //@{
    /// Test if the cursor may move to the first child node
    bool mayMoveDownwards(void);
    /// Process node
    void processCurrentNode(void);
    //@}
  };
  
  /// \brief A cursor that marks all nodes in the tree as not hidden
  class UnhideAllCursor : public NodeCursor<VisualNode> {
  public:
    /// Constructor
    UnhideAllCursor(VisualNode* theNode);
    /// \name Cursor interface
    //@{
    /// Process node
    void processCurrentNode(void);
    //@}
  };
  
}}

#include "gecode/gist/nodecursor.icc"

#endif

// STATISTICS: gist-any
