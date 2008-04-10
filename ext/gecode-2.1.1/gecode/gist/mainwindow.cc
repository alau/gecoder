/*
 *  Main authors:
 *     Guido Tack <tack@gecode.org>
 *
 *  Copyright:
 *     Guido Tack, 2006
 *
 *  Last modified:
 *     $Date: 2008-02-15 10:33:03 +0100 (Fri, 15 Feb 2008) $ by $Author: tack $
 *     $Revision: 6172 $
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

#include "gecode/gist/mainwindow.hh"
#include "gecode/gist/preferences.hh"
#include "gecode/gist/drawingcursor.hh"

#include "gecode/gist/gecodelogo.icc"

namespace Gecode { namespace Gist {
  
  class StatusBarNode : public QWidget {
  public:
    StatusBarNode(NodeStatus s) : status(s) {
      setMinimumSize(22,22);
      setMaximumSize(22,22);
    }
  protected:
    NodeStatus status;
    void paintEvent(QPaintEvent*) {
      QPainter painter(this);
      painter.setRenderHint(QPainter::Antialiasing);
      int hw= width()/2;
      int myx = hw+2; int myy = 2;
      switch (status) {
        case SOLVED:
          {
            QPoint points[4] = {QPoint(myx,myy),
                                QPoint(myx+8,myy+8),
                                QPoint(myx,myy+16),
                                QPoint(myx-8,myy+8)
                               };
            painter.setBrush(QBrush(DrawingCursor::green));
            painter.drawConvexPolygon(points, 4);            
          }
          break;
        case FAILED:
          {
            painter.setBrush(QBrush(DrawingCursor::red));
            painter.drawRect(myx-6, myy+2, 12, 12);
          }
          break;
        case BRANCH:
          {
            painter.setBrush(QBrush(DrawingCursor::blue));
            painter.drawEllipse(myx-8, myy, 16, 16);            
          }
          break;
        case UNDETERMINED:
          {
            painter.setBrush(QBrush(Qt::white));
            painter.drawEllipse(myx-8, myy, 16, 16);            
          }
          break;
        default:
          break;
      }
      
    }
  };
  
  AboutGist::AboutGist(QWidget* parent) : QDialog(parent) {

    QPixmap myPic;
    myPic.loadFromData(logo, sizeof(logo));

    setMinimumWidth(300);
    setMaximumWidth(300);
    QVBoxLayout* layout = new QVBoxLayout();
    QLabel* logo = new QLabel();
    logo->setPixmap(myPic);
    layout->addWidget(logo, 0, Qt::AlignCenter);
    QLabel* aboutLabel =
      new QLabel(tr("<h2>Gist</h2>"
                     "<p><b>The Gecode Interactive Search Tool</b</p> "
                    "<p>You can find more information about Gecode and Gist "
                    "at</p>"
                    "<p><a href='http://www.gecode.org'>www.gecode.org</a>"
                    "</p"));
    aboutLabel->setOpenExternalLinks(true);
    aboutLabel->setWordWrap(true);
    aboutLabel->setAlignment(Qt::AlignCenter);
    layout->addWidget(aboutLabel);
    setLayout(layout);
    setWindowTitle(tr("About Gist"));
    setAttribute(Qt::WA_QuitOnClose, false);
    setAttribute(Qt::WA_DeleteOnClose, false);
  }
  
  GistMainWindow::GistMainWindow(Space* root, Better* b,
                                 Gist::Inspector* gi)
  : c(root,b,this), aboutGist(this) {
    if (gi != NULL)
      c.setInspector(gi);
    setCentralWidget(&c);
    setWindowTitle(tr("Gist"));
    resize(500,500);

    menuBar = new QMenuBar(0);

    QMenu* fileMenu = menuBar->addMenu(tr("&File"));
    fileMenu->addAction(c.print);
    fileMenu->addAction(c.exportPostscript);
    QAction* quitAction = fileMenu->addAction(tr("Quit"));
    quitAction->setShortcut(QKeySequence("Ctrl+Q"));
    connect(quitAction, SIGNAL(triggered()),
            this, SLOT(close()));
    QAction* prefAction = fileMenu->addAction(tr("Preferences"));
    connect(prefAction, SIGNAL(triggered()), this, SLOT(preferences()));
    
    QMenu* nodeMenu = menuBar->addMenu(tr("&Node"));
    nodeMenu->addAction(c.inspectCN);
    nodeMenu->addAction(c.setPath);
    nodeMenu->addAction(c.inspectPath);
    nodeMenu->addSeparator();
    nodeMenu->addAction(c.navUp);
    nodeMenu->addAction(c.navDown);
    nodeMenu->addAction(c.navLeft);
    nodeMenu->addAction(c.navRight);
    nodeMenu->addAction(c.navRoot);
    nodeMenu->addSeparator();
    nodeMenu->addAction(c.toggleHidden);
    nodeMenu->addAction(c.hideFailed);
    nodeMenu->addAction(c.unhideAll);
    nodeMenu->addSeparator();
    nodeMenu->addAction(c.zoomToFit);
    nodeMenu->addAction(c.centerCN);
    
    QMenu* searchMenu = menuBar->addMenu(tr("&Search"));
    searchMenu->addAction(c.searchNext);
    searchMenu->addAction(c.searchAll);
    searchMenu->addSeparator();
    searchMenu->addAction(c.stopCN);
    searchMenu->addSeparator();
    searchMenu->addAction(c.reset);

    QMenu* toolsMenu = menuBar->addMenu(tr("&Tools"));
    toolsMenu->addAction(c.analyzeTree);
    toolsMenu->addSeparator();
    toolsMenu->addAction(c.toggleHeatView);
    toolsMenu->addAction(c.addVisualisation);
    
    QMenu* helpMenu = menuBar->addMenu(tr("&Help"));
    QAction* aboutAction = helpMenu->addAction(tr("About"));
    connect(aboutAction, SIGNAL(triggered()),
            this, SLOT(about()));

    // Don't add the menu bar on Mac OS X
#ifndef Q_WS_MAC
    setMenuBar(menuBar);
#endif

    // Set up status bar
    QWidget* stw = new QWidget();
    QHBoxLayout* hbl = new QHBoxLayout();
    hbl->setContentsMargins(0,0,0,0);
    hbl->addWidget(new StatusBarNode(SOLVED));
    solvedLabel = new QLabel("0");
    hbl->addWidget(solvedLabel);
    hbl->addWidget(new StatusBarNode(FAILED));
    failedLabel = new QLabel("0");
    hbl->addWidget(failedLabel);
    hbl->addWidget(new StatusBarNode(BRANCH));
    choicesLabel = new QLabel("0");
    hbl->addWidget(choicesLabel);
    hbl->addWidget(new StatusBarNode(UNDETERMINED));
    openLabel = new QLabel("     0");
    hbl->addWidget(openLabel);
    stw->setLayout(hbl);
    statusBar()->addPermanentWidget(stw);
    
    isSearching = false;
    
    connect(&c,SIGNAL(statusChanged(const Statistics&,bool)),
            this,SLOT(statusChanged(const Statistics&,bool)));
    
    show();
    PreferencesDialog pd(this);
    c.setAutoHideFailed(pd.hideFailed);
    c.setAutoZoom(pd.zoom);    
  }

  void
  GistMainWindow::closeEvent(QCloseEvent* event) {
    c.finish();
    event->accept();
  }

  void
  GistMainWindow::statusChanged(const Statistics& stats, bool finished) {
    if (isSearching && finished) {
      statusBar()->showMessage("Ready");
      isSearching = false;
    } else if (!isSearching && !finished) {
      statusBar()->showMessage("Searching");
      isSearching = true;
    }
    solvedLabel->setNum(stats.solutions);
    failedLabel->setNum(stats.failures);
    choicesLabel->setNum(stats.choices);
    openLabel->setNum(stats.undetermined);
  }

  void
  GistMainWindow::about(void) {
    aboutGist.show();
  }

  void
  GistMainWindow::preferences(void) {
    PreferencesDialog pd(this);
    if (pd.exec() == QDialog::Accepted) {
      c.setAutoHideFailed(pd.hideFailed);
      c.setAutoZoom(pd.zoom);
      c.setRefresh(pd.refresh);
    }
  }

}}

// STATISTICS: gist-any
