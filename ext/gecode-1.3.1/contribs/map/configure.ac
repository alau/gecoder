dnl
dnl Author:
dnl   Grégoire Dooms
dnl
dnl Copyright:
dnl   Université catholique de Louvain, 2005
dnl
dnl Large parts taken from the gecode configure.ac


AC_REVISION([$Revision$])
AC_PREREQ(2.53)
AC_INIT(CPMAP, 0.1, sz@info.ucl.ac.be)
AC_CONFIG_SRCDIR(map.hh)

dnl the names of the generated dlls
AC_SUBST(MAP,     "map")


AC_ARG_WITH(boost-include, 
            [  --with-boost-include=DIR     Specify where to find the boost include files
                             (default=/usr/include)], 
	    boost_include=$withval,
	    boost_include=/usr/include)

AC_SUBST(BOOST_DIR,"$boost_include")

../../config.status --file Makefile.in:Makefile.in.in

AC_CONFIG_COMMANDS([Makefile.in]) 
AC_CONFIG_FILES([Makefile])
AC_OUTPUT
