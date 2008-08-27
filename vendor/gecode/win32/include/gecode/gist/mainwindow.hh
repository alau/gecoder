/*
 *  Main authors:
 *     Guido Tack <tack@gecode.org>
 *
 *  Copyright:
 *     Guido Tack, 2006
 *
 *  Last modified:
 *     $Date: 2008-07-11 10:15:49 +0200 (Fri, 11 Jul 2008) $ by $Author: tack $
 *     $Revision: 7318 $
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

#ifndef GECODE_GIST_MAINWINDOW_HH
#define GECODE_GIST_MAINWINDOW_HH

#include "gecode/gist/treecanvas.hh"

namespace Gecode { namespace Gist {
  
  class AboutGist : public QDialog {
  public:
    AboutGist(QWidget* parent = 0);
  };
  
  /// \brief Main window for stand-alone %Gist
  class GistMainWindow : public QMainWindow {
    Q_OBJECT
  protected:
    /// The contained tree canvas
    TreeCanvas c;
    /// A menu bar
    QMenuBar* menuBar;
    /// About dialog
    AboutGist aboutGist;
    
    /// Whether search is currently running
    bool isSearching;
    /// Status bar label for number of solutions
    QLabel* solvedLabel;
    /// Status bar label for number of failures
    QLabel* failedLabel;
    /// Status bar label for number of choices
    QLabel* choicesLabel;
    /// Status bar label for number of open nodes
    QLabel* openLabel;
  protected Q_SLOTS:
    void statusChanged(const Statistics& stats, bool finished);
    void about(void);
    void preferences(bool setup=false);
  public:
    /// Constructor
    GistMainWindow(Space* root, Better* b, Gist::Inspector* gi);
  protected:
    void closeEvent(QCloseEvent* event);
  };
  
}}

#endif


// STATISTICS: gist-any
