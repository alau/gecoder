/*
 *  Main authors:
 *     Guido Tack <tack@gecode.org>
 *
 *  Copyright:
 *     Guido Tack, 2006
 *
 *  Last modified:
 *     $Date: 2008-07-11 15:48:58 +0200 (Fri, 11 Jul 2008) $ by $Author: schulte $
 *     $Revision: 7366 $
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

#ifndef GECODE_GIST_LAYOUTCURSOR_HH
#define GECODE_GIST_LAYOUTCURSOR_HH

#include "gecode/gist/nodecursor.hh"
#include "gecode/gist/visualnode.hh"

namespace Gecode { namespace Gist {
  
  /// \brief Layout parameters
  class Layout {
  public:
    static const int dist_y = 38;
    static const int extent = 20;
    static const int minimalSeparation = 10;
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

}}

#include "gecode/gist/layoutcursor.icc"

#endif

// STATISTICS: gist-any
