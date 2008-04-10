/*
 *  Main authors:
 *     Guido Tack <tack@gecode.org>
 *
 *  Copyright:
 *     Guido Tack, 2006
 *
 *  Last modified:
 *     $Date: 2007-12-03 13:33:28 +0100 (Mon, 03 Dec 2007) $ by $Author: tack $
 *     $Revision: 5559 $
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

#ifndef GECODE_GIST_TEXTOUTPUT_HH
#define GECODE_GIST_TEXTOUTPUT_HH

#include <QMainWindow>
#include <QTextEdit>

namespace Gecode { namespace Gist {
  /// \brief Window with associated ostream, used for inspecting Gist nodes
  class TextOutput : public QMainWindow {
  private:
    /// The QTextEditor used for text display
    QTextEdit *editor;
    /// The ostream that prints to the editor
    std::ostream *os;

  public:
    /// Constructor
    TextOutput(const std::string& name, QWidget *parent = 0);
    /// Destructor
    ~TextOutput(void);
    /// Return stream that prints to the text display
    std::ostream& getStream(void);
    /// Add html string \a s to the output
    void insertHtml(const QString& s);
  };

}}

#endif

// STATISTICS: gist-any
