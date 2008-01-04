dnl
dnl Author:
dnl   Grégoire Dooms
dnl
dnl Copyright:
dnl   Gregoire Dooms (Université catholique de Louvain), 2005
dnl
dnl Large parts taken from the gecode configure.ac


AC_REVISION([$Revision: 271 $])
AC_PREREQ(2.53)
AC_INIT(CPGRAPH, 0.1, dooms@info.ucl.ac.be)
AC_CONFIG_SRCDIR(graph.hh)

dnl the names of the generated dlls
AC_SUBST(GRAPH,     "graph")


AC_ARG_WITH(boost-include, 
            [  --with-boost-include=DIR     Specify where to find the boost include files
                             (default=/usr/include)], 
	    boost_include=$withval,
	    boost_include=/usr/include)

AC_SUBST(BOOST_DIR,"$boost_include")
HDRS=`find . -name \*.icc -or -name \*.hh` 
#AC_SUBST(GRAPHHDR,$HDRS) # does not work
../../config.status --file Makefile.in:Makefile.in.in
AC_CONFIG_COMMANDS([Makefile.in]) 

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
