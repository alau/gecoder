/*
 *  Main authors:
 *     Niko Paltzer <nikopp@ps.uni-sb.de>
 *
 *  Copyright:
 *     Niko Paltzer, 2007
 *
 *  Last modified:
 *     $Date: 2008-02-04 21:46:50 +0100 (Mon, 04 Feb 2008) $ by $Author: nikopp $
 *     $Revision: 6051 $
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

#ifndef GECODE_GIST_VISUALISATION_VARARRAYVIEW_HH
#define GECODE_GIST_VISUALISATION_VARARRAYVIEW_HH

#include <QtGui/QGraphicsView>
#include <QtGui/QSlider>
#include <QtGui/QGridLayout>
#include <QtGui/QPushButton>
#include <QtCore/QString>

#include "gecode/minimodel.hh"

#include "gecode/gist/visualisation/vararrayitem.hh"

namespace Gecode { namespace Gist { namespace Visualisation {

  class VarArrayView : public QWidget {

    Q_OBJECT

  public:
    VarArrayView(Gecode::Reflection::VarMap& vm, int pit, QStringList vars, QWidget *parent = 0);

  public Q_SLOTS:
    void display(Gecode::Reflection::VarMap&, int pit);
    void displayOld(int pit); ///< Use to show the variable at point in time pit

  Q_SIGNALS:
    void pointInTimeChanged(int pit);

  private Q_SLOTS:
    void on_muteButton_clicked(void);
    
  protected:
    void init(void);
    
    virtual void initT(QVector<Reflection::VarSpec*> specs) = 0;
    virtual void displayT(QVector<Reflection::VarSpec*> spec) = 0;
    virtual void displayOldT(int pit) = 0;

    void extendTimeBar(int pit);
    void updateTimeBar(int pit);
    
    QGridLayout* grid;
    QGraphicsScene* scene;
    QGraphicsView* view;
    QSlider* timeBar;
    QPushButton* resetButton;
    QPushButton* muteButton;
    Gecode::Reflection::VarMap& vm;
    bool muted;
    int nextInternalPit;
    QStringList vars;
    QVector<int> pitMap;
  };

}}}

#endif

// STATISTICS: gist-any
