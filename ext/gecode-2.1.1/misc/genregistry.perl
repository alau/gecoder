#!/usr/bin/perl -w
#
#  Main authors:
#     Guido Tack <tack@gecode.org>
#
#  Copyright:
#     Guido Tack, 2008
#
#  Last modified:
#     $Date: 2008-02-05 18:31:20 +0100 (Tue, 05 Feb 2008) $ by $Author: schulte $
#     $Revision: 6066 $
#
#  This file is part of Gecode, the generic constraint
#  development environment:
#     http://www.gecode.org
#
#  Permission is hereby granted, free of charge, to any person obtaining
#  a copy of this software and associated documentation files (the
#  "Software"), to deal in the Software without restriction, including
#  without limitation the rights to use, copy, modify, merge, publish,
#  distribute, sublicense, and/or sell copies of the Software, and to
#  permit persons to whom the Software is furnished to do so, subject to
#  the following conditions:
#
#  The above copyright notice and this permission notice shall be
#  included in all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
#  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
#  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
#  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
#  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
#

%ignore = ("init" => "", "NodeType" => "");

print <<EOF
/*
 *  CAUTION:
 *    This file has been automatically generated. Do not edit,
 *    edit the following files instead:
EOF
;

foreach $file (@ARGV) {
  print " *     - $file\n";
}

print <<EOF
 *
 *  This file contains generated code fragments which are
 *  copyrighted as follows:
 *
 *  Main author:
 *     Guido Tack <tack\@gecode.org>
 *
 *  Copyright:
 *     Guido Tack, 2008
 *
 *  The generated code fragments are part of Gecode, the generic
 *  constraint development environment:
 *     http://www.gecode.org
 *
 *  Permission is hereby granted, free of charge, to any person obtaining
 *  a copy of this software and associated documentation files (the
 *  "Software"), to deal in the Software without restriction, including
 *  without limitation the rights to use, copy, modify, merge, publish,
 *  distribute, sublicense, and/or sell copies of the Software, and to
 *  permit persons to whom the Software is furnished to do so, subject to
 *  the following conditions:
 *
 *  The above copyright notice and this permission notice shall be
 *  included in all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 *  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 *  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 *  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 *  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 *  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 *  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */

EOF
;

my %postFunctions;
my %enumerations = ("PropKind" => [ ("gecode/kernel.hh",
                                     "PK_DEF", "PK_SPEED", "PK_MEMORY") ]);

my %ifdefs = ("gecode/kernel.hh" => "1");

# Collect post functions from header files, filenames given on command line
foreach $file (@ARGV) {

  open HEADERFILE, $file || die "open failed";

  $currentPost = "";
  $currentEnum = "";
  my @enumArgs;
  $withinPost = 0;
  $withinEnum = 0;
  while ($l = <HEADERFILE>) {
    if ($l =~ /\/\/ IFDEF: (.*)/) {
      $ifdefs{$file} = "defined($1)";
    }
    if ($l =~ /GECODE_[A-Z]+_EXPORT.*void(.*)/) {
      $currentPost = $1;
      chomp($currentPost);
      $withinPost = 1;
    } elsif ($l =~ /inline void(.*)/) {
      $currentPost = $1;
      chomp($currentPost);
      $withinPost = 1;
    } elsif ($withinPost == 1) {
      chomp($l);
      $l =~ s/ [ ]+/ /g;
      $currentPost .= $l;
    } elsif ($l =~ /enum ([a-zA-Z]+)(.*)/) {
      if (not exists $ignore{$1}) {
        $withinEnum = 1;
        $currentEnum = $1;
        @enumArgs = ();
        $l = $2;
      }
    }
    if ($withinEnum == 1) {
      if ($l =~ /([A-Z]+_[A-Z_]+)/) {
        push(@enumArgs, $1);
      }
      if ($l =~ /};/) {
        $withinEnum = 0;
        unshift(@enumArgs, $file);
        $enumerations{$currentEnum} = [ @enumArgs ];
      }
    }
    if ($withinPost && $l =~ /;/) {
      $withinPost = 0;
      if ($currentPost =~ 
          /([a-z][a-zA-Z_]*)\(Space\s*\*\s*home\s*,\s*([^)]*)\)/) 
      {
        my $postFunName = $1;
        if (exists $ignore{$postFunName}) {
          print STDERR "Ignoring function $postFunName\n";
        } else {
          @args = split(/,/, $2);
          # Push full version
          my @processedArgs = processArgs(@args);
          if (recognized(@processedArgs)) {
            unshift(@processedArgs, $file);
            push(@{$postFunctions{$postFunName}}, [ @processedArgs ]);
          } else {
            print STDERR "ignored:\n  $currentPost\n";
          }
          # If function has default arguments, push shorter versions, too
          for ($i=@args-1; $i >= 0; $i--) {
            if ($args[$i] =~ /=/) {
              my @shorterArgs;
              for ($j=0; $j<$i; $j++) {
                $shorterArgs[$j] = $args[$j];
              }
              @processedArgs = processArgs(@shorterArgs);
              if (recognized(@processedArgs)) {
                unshift(@processedArgs, $file);
                push(@{$postFunctions{$postFunName}}, [ @processedArgs ]);
              }
            }
          }
        }
      }
    }
  }
}

# Sort post function argument lists by length (arity)
foreach $key (keys %postFunctions) {
  $postFunctions{$key} = [ sort {@{$a} <=> @{$b}} (@{$postFunctions{$key}}) ];
}

print "#include \"gecode/kernel.hh\"\n";

foreach $file (@ARGV) {
  print "#if $ifdefs{$file}\n";
  print "#include \"$file\"\n";
  print "#endif\n";
}

print <<EOF

#include "gecode/serialization.hh"

namespace {
EOF
;

foreach $e (keys %enumerations) {
my $file = shift(@{$enumerations{$e}});
my $ifdef = $ifdefs{$file};
  print <<EOF
#if $ifdef
Gecode::$e toEnum_$e(Gecode::Reflection::Arg* a) {
  assert(a->isString());
  const char* av = a->toString();
EOF
;
  foreach $ev (@{$enumerations{$e}}) {
    print "  if (!strcmp(av, \"$ev\"))\n";
    print "    return Gecode::$ev;\n"
  }
  print <<EOF
  throw Gecode::Reflection::ReflectionException("Internal error");
}
bool isEnum_$e(Gecode::Reflection::Arg* a) {
  if (!a->isString())
    return false;
  const char* av = a->toString();
EOF
  ;
  foreach $ev (@{$enumerations{$e}}) {
    print "  if (!strcmp(av, \"$ev\"))\n";
    print "    return true;\n"
  }
  print "  return false;\n";
  print "}\n";
  print "#endif\n";
}

print <<EOF

/// Check if \\a a corresponds to a variable in \\a vm with type \\a Var
template <class Var>
bool isVar(Gecode::Reflection::VarMap& vm, Gecode::Reflection::Arg* a) {
  if (!a->isVar())
    return false;
  Gecode::Reflection::VarSpec& s = vm.spec(a->toVar());
  typedef typename Gecode::VarViewTraits<Var>::View View;
  typedef typename Gecode::ViewVarImpTraits<View>::VarImp VarImp;
  return s.vti() == VarImp::vti;
}

/// Check if \\a a corresponds to an array of \\a Var variables in \\a vm
template <class Var>
bool isVarArgs(Gecode::Reflection::VarMap& vm, Gecode::Reflection::Arg* a) {
  if (!a->isArray())
    return false;
  Gecode::Reflection::ArrayArg& aa = *a->toArray();
  for (int i=aa.size(); i--;)
    if (!isVar<Var>(vm, aa[i]))
      return false;
  return true;
}

bool isIntSetArgs(Gecode::Reflection::Arg* a) {
  if (!a->isArray())
    return false;
  Gecode::Reflection::ArrayArg& aa = *a->toArray();
  for (int i=aa.size(); i--;)
    if (!aa[i]->isIntArray())
      return false;
  return true;
}

EOF
;

# Output one registration class per (overloaded) post function name
foreach $key (keys %postFunctions) {
  print <<EOF
class Register_$key {
public:
  /// Identifier for this post function
  static Gecode::Support::Symbol ati(void) {
    return \"Gecode::Post::$key\";
  }
  
  /// Post constraint described by \\a spec
  static void post(Gecode::Space* home, Gecode::Reflection::VarMap& vm,
                   const Gecode::Reflection::ActorSpec& spec) {
    switch(spec.noOfArgs()) {
EOF
;
  
  $arity = -1;
  foreach $f (@{$postFunctions{$key}}) {
    my $file = shift (@{$f});
    if ($arity != scalar(@{$f})) {
      if ($arity >= 0) {
        print "        throw Gecode::Reflection::ReflectionException(\"Argument type mismatch for Gecode::Post::$key\");\n";
        print "      }\n";
        print "      break;\n";
      }
      $arity = scalar(@{$f});
      print "    case $arity:\n";
      print "      {\n";
    }

    my $ifdef = $ifdefs{$file};
    print "#if $ifdef\n";
    # Check arguments
    print   "        if (";
    my $count = 0;
    my @args = @{$f};
    foreach $a (@args) {
      outputArgCond($a, $count);
      if ($count < scalar(@args)-1) {
        print " &&\n            ";
      }
      $count++;
    }
    print ")\n        {\n";

    # Declare arguments
    $count = 0;
    foreach $a (@args) {
      outputArg($a, $count);
      $count++;
    }
    
    
    # Post constraint
    print "          Gecode::$key(home, ";
    for (my $i=0; $i<$count; $i++) {
      print "x$i";
      if ($i<$count-1) {
        print ",";
      }
    }    
    print ");\n";
    print "          return;\n";
    print "        }\n";
    print "#endif\n";
  }
  if ($arity >= 0) {
    print "        throw Gecode::Reflection::ReflectionException(\"Argument type mismatch for Gecode::Post::$key\");\n";
    print "      }\n";
    print "      break;\n";
  }
  print "    default: throw Gecode::Reflection::ReflectionException(\"Argument type mismatch for Gecode::Post::$key\");\n";
  print "    }\n";
  print "  }\n";
  print "};\n\n";
}

print "class PostRegistrar {\n";
foreach $key (keys %postFunctions) {
  print "  GECODE_REGISTER1(Register_$key);\n";
}
print "};\n\n";

print "} // end anonymous namespace\n";

print <<EOF
namespace Gecode { namespace Serialization {
  
  void initRegistry(void) {
    static PostRegistrar r;
    return;
  };

  
}}
EOF
;

sub processArgs {
  my @args = @_;
  foreach (@args) {
    s/\s*(const)*\s*(unsigned int|[a-zA-Z]+).*/$2/;
  }
  return @args;
}

sub recognized {
  foreach $a (@_) {
    if ($a eq "int" || $a eq "unsigned int" || $a eq "bool") {
    } elsif ($a =~ /([a-zA-Z]+)VarArgs$/) {
    } elsif ($a =~ /([a-zA-Z]+)Var$/) {
    } elsif ($a eq "IntArgs") {
    } elsif ($a eq "IntSetArgs") {
    } elsif ($a eq "IntSet") {
    } elsif (exists $enumerations{$a}) {
    } else {
      return 0;
    }
  }
  return 1;
}

sub outputArgCond {
  if ($_[0] eq "int" || $_[0] eq "unsigned int" || $_[0] eq "bool") {
    print "spec[$_[1]]->isInt()";
  } elsif ($_[0] =~ /([a-zA-Z]+)VarArgs$/) {
    print "isVarArgs<Gecode::$1Var>(vm, spec[$_[1]])";
  } elsif ($_[0] =~ /([a-zA-Z]+)Var$/) {
    print "isVar<Gecode::$1Var>(vm, spec[$_[1]])";
  } elsif ($_[0] eq "IntArgs") {
    print "spec[$_[1]]->isIntArray()";
  } elsif ($_[0] eq "IntSetArgs") {
    print "isIntSetArgs(spec[$_[1]])";
  } elsif ($_[0] eq "IntSet") {
    print "spec[$_[1]]->isIntArray()";
  } elsif (exists $enumerations{$_[0]}) {
    print "isEnum_$_[0](spec[$_[1]])";
  } else {
    print "unknown($_[0])";
  }
}

sub outputArg {
  if ($_[0] eq "int" || $_[0] eq "unsigned int" || $_[0] eq "bool") {
    print "          ";
    print "$_[0] x$_[1] = static_cast<$_[0]>(spec[$_[1]]->toInt());\n";
  } elsif ($_[0] =~ /([a-zA-Z]+)VarArgs$/) {
    print "          ";
    print "Gecode::Reflection::ArrayArg& a$_[1] = *spec[$_[1]]->toArray();\n";
    print "          ";
    print "Gecode::VarArgArray<Gecode::$1Var> x$_[1](a$_[1].size());\n";
    print "          ";
    print "for (int i=a".$_[1].".size(); i--;)\n";
    print "          ";
    print "  x$_[1]"."[i] = Gecode::$1Var(vm.var(a$_[1]"."[i]->toVar()));\n"
  } elsif ($_[0] =~ /([a-zA-Z]+)Var$/) {
    print "          ";
    print "Gecode::$1Var x$_[1](vm.var(spec[$_[1]]->toVar()));\n"
  } elsif ($_[0] eq "IntArgs") {
    print "          ";
    print "Gecode::Reflection::IntArrayArg& a$_[1] = ".
          "*spec[$_[1]]->toIntArray();\n";
    print "          ";
    print "Gecode::IntArgs x$_[1](a$_[1].size());\n";
    print "          ";
    print "for (int i=a".$_[1].".size(); i--;) ".
          "x$_[1]"."[i] = a$_[1]"."[i];\n"
  } elsif ($_[0] eq "IntSetArgs") {
    print "          ";
    print "Gecode::Reflection::ArrayArg& a$_[1] = *spec[$_[1]]->toArray();\n";
    print "          ";
    print "Gecode::IntSetArgs x$_[1](a$_[1].size());\n";
    print "          ";
    print "for (int i=a".$_[1].".size(); i--;) {\n";

    print "            ";
    print "Gecode::Reflection::IntArrayArg* aa$_[1] = ".
          "a$_[1]"."[i]->toIntArray();\n";
    print "            ";
    print "Gecode::Reflection::IntArrayArgRanges aar$_[1](aa$_[1]);\n";
    print "            ";
    print "x$_[1]"."[i] = Gecode::IntSet(aar$_[1]);\n";
    print "          }\n";
  } elsif ($_[0] eq "IntSet") {
    print "          ";
    print "Gecode::Reflection::IntArrayArg* a$_[1] = ".
          "spec[$_[1]]->toIntArray();\n";
    print "          ";
    print "Gecode::Reflection::IntArrayArgRanges ar$_[1](a$_[1]);\n";
    print "          ";
    print "Gecode::IntSet x$_[1](ar$_[1]);\n";
  } elsif (exists $enumerations{$_[0]}) {
    print "          ";
    print "Gecode::$_[0] x$_[1] = toEnum_$_[0](spec[$_[1]]);\n";
  } else {
    print "unknown($_[0])";
  }  
}
