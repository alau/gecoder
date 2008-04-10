/*
 *  Main authors:
 *     Niko Paltzer <nikopp@ps.uni-sb.de>
 *
 *  Copyright:
 *     Niko Paltzer, 2007
 *
 *  Last modified:
 *     $Date: 2008-02-01 12:10:00 +0100 (Fri, 01 Feb 2008) $ by $Author: schulte $
 *     $Revision: 6034 $
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

#include "gecode/gist/config.hh"

#include "gecode/gist/visualisation/vararrayviewt.hh"
#ifdef GECODE_HAS_INT_VARS
#include "gecode/gist/visualisation/intvaritem.hh"
#endif
#ifdef GECODE_HAS_SET_VARS
#include "gecode/gist/visualisation/setvaritem.hh"
#endif

namespace Gecode { namespace Gist {

  Config::Config(void)
    {
#ifdef GECODE_HAS_INT_VARS
      visualisationMap.insert("IntVarArray", &Visualisation::VarArrayViewT<Visualisation::IntVarItem>::create);
#endif
#ifdef GECODE_HAS_SET_VARS
      visualisationMap.insert("SetVarArray", &Visualisation::VarArrayViewT<Visualisation::SetVarItem>::create);
#endif
    }

}}

// STATISTICS: gist-any
