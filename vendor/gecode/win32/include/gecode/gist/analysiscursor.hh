/*
 *  Main authors:
 *     Guido Tack <tack@gecode.org>
 *
 *  Copyright:
 *     Guido Tack, 2006
 *
 *  Last modified:
 *     $Date: 2007-12-02 17:24:21 +0100 (Sun, 02 Dec 2007) $ by $Author: schulte $
 *     $Revision: 5544 $
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

#ifndef GECODE_GIST_ANALYSISCURSOR_HH
#define GECODE_GIST_ANALYSISCURSOR_HH

#include "gecode/gist/nodecursor.hh"

namespace Gecode { namespace Gist {

  /// \brief A cursor that analyses the tree
  class AnalysisCursor : public NodeCursor<VisualNode> {
  private:
    int& minHeat;
    int& maxHeat;
    
    void processTopDown(void);
  public:
    /// Constructor
    AnalysisCursor(VisualNode* root, int& min, int& max);

    ///\name Cursor interface
    //@{
    void moveDownwards(void);
    void moveSidewards(void);
    void processCurrentNode(void);
    //@}
  };

  class DistributeCursor : public NodeCursor<VisualNode> {
  private:
    int minHeat;
    int maxHeat;
  public:
    /// Constructor
    DistributeCursor(VisualNode* root, int min, int max);
    void processCurrentNode(void);
  };

}}

#endif

// STATISTICS: gist-any
