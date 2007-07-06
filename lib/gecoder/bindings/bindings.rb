# Copyright (c) 2007, David Cuadrado <krawek@gmail.com>
# All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.


RUST_PATH = File.dirname(__FILE__) + '/../../../vendor/rust'
$:.unshift(RUST_PATH) unless $:.include?(RUST_PATH)
require 'rust'

ruby2intargs = %@

bool is_Gecode_IntArgs(VALUE arr)
{
  return is_array(arr);
}

Gecode::IntArgs ruby2Gecode_IntArgs(VALUE arr, int argn = -1);
Gecode::IntArgs ruby2Gecode_IntArgs(VALUE arr, int argn)
{
  RArray *array = RARRAY(arr);
  Gecode::IntArgs intargs(array->len);
  for(int i = 0; i < array->len; i++)
  {
    intargs[i] = NUM2INT(array->ptr[i]);
  }
  
  return intargs;
}
@


Rust::Bindings::create_bindings Rust::Bindings::LangCxx, "gecode" do |b|
  b.include_header 'gecode/kernel.hh', Rust::Bindings::HeaderGlobal
  b.include_header 'gecode/int.hh', Rust::Bindings::HeaderGlobal
  b.include_header 'gecode/search.hh', Rust::Bindings::HeaderGlobal
  b.include_header 'gecode/minimodel.hh', Rust::Bindings::HeaderGlobal
  b.include_header 'missing.h', Rust::Bindings::HeaderLocal
  
  b.add_custom_definition ruby2intargs
  
  # Is it possible to use namespaces with multiple levels in Rust? I.e. use
  # Gecode::Raw instead of GecodeRaw here (and avoid the hidious renaming)
  # when requiring them.
  b.add_namespace "GecodeRaw", "Gecode" do |ns|
    ns.add_enum "BvarSel" do |enum|
      enum.add_value "BVAR_NONE"
      enum.add_value "BVAR_MIN_MIN"
      enum.add_value "BVAR_MIN_MAX"
      enum.add_value "BVAR_MAX_MIN"
      enum.add_value "BVAR_MAX_MAX"
      enum.add_value "BVAR_SIZE_MIN"
      enum.add_value "BVAR_SIZE_MAX"
      enum.add_value "BVAR_DEGREE_MAX"
      enum.add_value "BVAR_DEGREE_MIN"
      enum.add_value "BVAR_REGRET_MIN_MIN"
      enum.add_value "BVAR_REGRET_MIN_MAX"
      enum.add_value "BVAR_REGRET_MAX_MIN"
      enum.add_value "BVAR_REGRET_MAX_MAX"
    end
    
    ns.add_enum "SetBvarSel" do |enum|
      enum.add_value "SETBVAR_NONE"
      enum.add_value "SETBVAR_MIN_CARD"
      enum.add_value "SETBVAR_MAX_CARD"
      enum.add_value "SETBVAR_MIN_UNKNOWN_ELEM"
      enum.add_value "SETBVAR_MAX_UNKNOWN_ELEM"
    end
    
 		ns.add_enum "SetBvalSel" do |enum|
      enum.add_value "SETBVAL_MIN"
      enum.add_value "SETBVAL_MAX"
    end
 		
    
    ns.add_enum "BvalSel" do |enum|
      enum.add_value "BVAL_MIN"
      enum.add_value "BVAL_MED"
      enum.add_value "BVAL_MAX"
      enum.add_value "BVAL_SPLIT_MIN"
      enum.add_value "BVAL_SPLIT_MAX"
    end
    
    ns.add_enum "IntRelType" do |enum|
      enum.add_value "IRT_EQ"
      enum.add_value "IRT_NQ"
      enum.add_value "IRT_LQ"
      enum.add_value "IRT_LE"
      enum.add_value "IRT_GQ"
      enum.add_value "IRT_GR"
    end
    
    ns.add_enum "SetRelType" do |enum|
      enum.add_value "SRT_EQ"
      enum.add_value "SRT_NQ"
      enum.add_value "SRT_SUB"
      enum.add_value "SRT_SUP"
      enum.add_value "SRT_DISJ"
      enum.add_value "SRT_CMPL"
    end
    
    ns.add_enum "SetOpType " do |enum|
      enum.add_value "SOT_UNION"
      enum.add_value "SOT_DUNION"
      enum.add_value "SOT_INTER"
      enum.add_value "SOT_MINUS"
    end
    
    ns.add_enum "IntConLevel" do |enum|
      enum.add_value "ICL_VAL"
      enum.add_value "ICL_BND"
      enum.add_value "ICL_DOM"
      enum.add_value "ICL_DEF"
    end
    
    ns.add_enum "SpaceStatus" do |enum|
      enum.add_value "SS_FAILED"
      enum.add_value "SS_SOLVED"
      enum.add_value "SS_BRANCH"
    end
    
    ns.add_enum "AvalSel" do |enum|
      enum.add_value "AVAL_MIN"
      enum.add_value "AVAL_MED"
      enum.add_value "AVAL_MAX"
    end
    
    ns.add_cxx_class "MIntVarArray" do |klass|
      klass.bindname = "IntVarArray"
      klass.add_constructor
      klass.add_constructor do |func|
        func.add_parameter "Gecode::MSpace *", "home"
        func.add_parameter "int", "n"
      end
      
      klass.add_constructor do |func|
        func.add_parameter "Gecode::MSpace *", "home"
        func.add_parameter "int", "n"
        func.add_parameter "int", "min"
        func.add_parameter "int", "max"
      end
      
      klass.add_constructor do |func|
        func.add_parameter "Gecode::MSpace *", "home"
        func.add_parameter "int", "n"
        func.add_parameter "Gecode::IntSet", "s"
      end
      
      klass.add_method "at", "Gecode::IntVar&" do |method|
        method.add_parameter "int", "index"
      end
      
      klass.add_operator "[]", "Gecode::IntVar&" do |method|
        method.add_parameter "int", "index"
      end
      
      klass.add_operator "[]=", "Gecode::IntVar&" do |method|
        method.add_parameter "int", "index"
        method.add_parameter "Gecode::IntVar", "val"
      end
      
      klass.add_method "size", "int"
      
      klass.add_method "debug"
      
    end
    
    
    ns.add_cxx_class "MBoolVarArray" do |klass|
      klass.bindname = "BoolVarArray"
      klass.add_constructor
      klass.add_constructor do |func|
        func.add_parameter "Gecode::MSpace *", "home"
        func.add_parameter "int", "n"
      end
      
      klass.add_method "at", "Gecode::BoolVar&" do |method|
        method.add_parameter "int", "index"
      end
      
      klass.add_operator "[]", "Gecode::BoolVar&" do |method|
        method.add_parameter "int", "index"
      end
      
      klass.add_operator "[]=", "Gecode::BoolVar&" do |method|
        method.add_parameter "int", "index"
        method.add_parameter "Gecode::BoolVar", "val"
      end
      
      klass.add_method "size", "int"
      
      klass.add_method "debug"
      
    end
    
    ns.add_cxx_class "MSetVarArray" do |klass|
      klass.bindname = "SetVarArray"
      klass.add_constructor
      
      klass.add_constructor do |method|
        method.add_parameter "Gecode::MSpace *", "home"
        method.add_parameter "int", "n"
      end
      
      klass.add_constructor do |method|
        method.add_parameter "Gecode::MSpace *", "home"
        method.add_parameter "int", "n"
        method.add_parameter "int", "glbMin"
        method.add_parameter "int", "glbMax"
        method.add_parameter "int", "lubMin"
        method.add_parameter "int", "lubMax"
        method.add_parameter "int", "minCard"
        method.add_parameter "int", "maxCard"
      end
      
      klass.add_constructor do |method|
        method.add_parameter "Gecode::MSpace *", "home"
        method.add_parameter "int", "n"
        method.add_parameter "Gecode::IntSet", "glb"
        method.add_parameter "int", "lubMin"
        method.add_parameter "int", "lubMax"
        method.add_parameter "int", "minCard", true
        method.add_parameter "int", "maxCard", true
      end
      
      klass.add_constructor do |method|
        method.add_parameter "Gecode::MSpace *", "home"
        method.add_parameter "int", "n"
        method.add_parameter "int", "glbMin"
        method.add_parameter "int", "glbMax"
        method.add_parameter "Gecode::IntSet", "lub"
        method.add_parameter "int", "minCard", true
        method.add_parameter "int", "maxCard", true
      end
      
      klass.add_constructor do |method|
        method.add_parameter "Gecode::MSpace *", "home"
        method.add_parameter "int", "n"
        method.add_parameter "Gecode::IntSet", "glb"
        method.add_parameter "Gecode::IntSet", "lub"
        method.add_parameter "int", "minCard", true
        method.add_parameter "int", "maxCard", true
      end
      
      klass.add_method "at", "Gecode::SetVar&" do |method|
        method.add_parameter "int", "index"
      end
      
      klass.add_operator "[]", "Gecode::SetVar&" do |method|
        method.add_parameter "int", "index"
      end
      
      klass.add_operator "[]=", "Gecode::SetVar&" do |method|
        method.add_parameter "int", "index"
        method.add_parameter "Gecode::SetVar", "val"
      end
      
      klass.add_method "size", "int"
      
      klass.add_method "debug"
    end
    
    ns.add_cxx_class "MBranchingDesc" do |klass|
      klass.bindname = "BranchingDesc"
      klass.add_constructor
      klass.add_method "alternatives", "int"
      klass.add_method "size", "int"
    end
    
    ns.add_cxx_class "MSpace" do |klass|
      klass.bindname = "Space"
      
      klass.add_constructor
      
      klass.add_method "debug"
      
      klass.add_method "own" do |method|
        method.add_parameter "Gecode::MIntVarArray *", "x"
        method.add_parameter "char*", "name"
      end
      
      klass.add_method "own" do |method|
        method.add_parameter "Gecode::MBoolVarArray *", "x"
        method.add_parameter "char*", "name"
      end
      
      klass.add_method "own" do |method|
        method.add_parameter "Gecode::MSetVarArray *", "x"
        method.add_parameter "char*", "name"
      end
      
      klass.add_method "intVarArray", "Gecode::MIntVarArray *" do |method|
        method.add_parameter "char *", "name"
      end
      
      klass.add_method "boolVarArray", "Gecode::MBoolVarArray *" do |method|
        method.add_parameter "char *", "name"
      end
      
      klass.add_method "setVarArray", "Gecode::MSetVarArray *" do |method|
        method.add_parameter "char *", "name"
      end
      
      klass.add_method "clone", "Gecode::MSpace *" do |method|
        method.add_parameter "bool", "shared"
      end
      
      klass.add_method "status", "int"
      
      klass.add_method "propagators", "int"
      klass.add_method "branchings", "int"
      klass.add_method "failed", "bool"
      klass.add_method "cached", "int"
      
      klass.add_method "mdescription", "Gecode::MBranchingDesc *", "description"
      
      klass.add_method "commit" do |method|
        method.add_parameter "Gecode::MBranchingDesc", "desc" do |param|
          param.custom_conversion = "ruby2Gecode_MBranchingDescPtr(desc, 1)->ptr()"
        end
        method.add_parameter "int", "a"
      end
    end
    
    ns.add_namespace "Limits" do |limitsns|
      limitsns.add_namespace "Int" do |intns|
        intns.add_constant "INT_MAX", "Gecode::Limits::Int::int_max"
        intns.add_constant "INT_MIN", "Gecode::Limits::Int::int_min"
        intns.add_constant "DOUBLE_MAX", "Gecode::Limits::Int::double_max"
        intns.add_constant "DOUBLE_MIN", "Gecode::Limits::Int::double_min"
      end
      limitsns.add_namespace "Set" do |setns|
        setns.add_constant "INT_MAX", "Gecode::Limits::Set::int_max"
        setns.add_constant "INT_MIN", "Gecode::Limits::Set::int_min"
        setns.add_constant "CARD_MAX", "Gecode::Limits::Set::card_max"
      end
    end
    
    ns.add_cxx_class "IntSet" do |klass|
      klass.add_constructor do |method|
        method.add_parameter "int", "min"
        method.add_parameter "int", "max"
      end
      
      klass.add_constructor do |method|
        method.add_parameter "int []", "r"
        method.add_parameter "int", "n"
      end
      
      klass.add_method "size", "int"
      
      klass.add_method "width", "unsigned int" do |method|
        method.add_parameter "int", "i"
      end
      
      klass.add_method "max", "int" do |method|
        method.add_parameter "int", "i"
      end
      
      klass.add_method "min", "int" do |method|
        method.add_parameter "int", "i"
      end
      
      klass.add_constant "Empty", "(Gecode::IntSet *)&Gecode::IntSet::empty"
    end
    
    ns.add_cxx_class "IntVar" do |klass|
      klass.add_constructor do |method|
        method.add_parameter "Gecode::MSpace*", "home"
        method.add_parameter "int", "min"
        method.add_parameter "int", "max"
      end
      
      klass.add_method "max", "int"
      
      klass.add_method "min", "int"
      klass.add_method "med", "int"
      klass.add_method "val", "int"
      klass.add_method "size", "unsigned int"
      klass.add_method "width", "unsigned int"
      klass.add_method "degree", "unsigned int"
      
      klass.add_method "range", "bool"
      klass.add_method "assigned", "bool"
      klass.add_method "in", "bool" do |method|
        method.add_parameter "int", "n"
      end
      
      klass.add_method "update" do |method|
        method.add_parameter "Gecode::MSpace*", "home"
        method.add_parameter "bool", "share"
        method.add_parameter "Gecode::IntVar", "x"
      end
      
      klass.add_operator "+", "Gecode::MiniModel::LinExpr" do |operator|
        operator.add_parameter("int", "i")
      end
      
      klass.add_operator "-", "Gecode::MiniModel::LinExpr" do |operator|
        operator.add_parameter("int", "i")
      end
      
      klass.add_operator "*", "Gecode::MiniModel::LinExpr" do |operator|
        operator.add_parameter("int", "i")
      end
      
      klass.add_operator "!=", "Gecode::MiniModel::LinRel", "different" do |operator|
        operator.add_parameter("Gecode::IntVar", "other")
      end
      
      klass.add_operator "==", "Gecode::MiniModel::LinRel", "equal" do |operator|
        operator.add_parameter("Gecode::IntVar", "other")
      end
      
    end
    
    ns.add_cxx_class "BoolVar" do |klass|
      klass.add_constructor
      klass.add_constructor do |method|
        method.add_parameter "Gecode::MSpace*", "home"
        method.add_parameter "int", "min"
        method.add_parameter "int", "max"
      end
      klass.add_constructor do |method|
        method.add_parameter "Gecode::IntVar", "x"
      end
      
      klass.add_method "max", "int"
      
      klass.add_method "min", "int"
      klass.add_method "med", "int"
      klass.add_method "val", "int"
      klass.add_method "size", "unsigned int"
      klass.add_method "width", "unsigned int"
      klass.add_method "degree", "unsigned int"
      
      klass.add_method "range", "bool"
      klass.add_method "assigned", "bool"
      klass.add_method "in", "bool" do |method|
        method.add_parameter "int", "n"
      end
      
      klass.add_method "update", "void" do |method|
        method.add_parameter "Gecode::MSpace*", "home"
        method.add_parameter "bool", "share"
        method.add_parameter "Gecode::BoolVar", "x"
      end
    end
    
    ns.add_cxx_class "SetVar" do |klass|
      klass.add_constructor
      klass.add_constructor do |method|
        method.add_parameter "Gecode::MSpace*", "home"
      end
      klass.add_constructor do |method|
        method.add_parameter "Gecode::MSpace*", "home"
        method.add_parameter "int", "glbMin"
        method.add_parameter "int", "glbMax"
        method.add_parameter "int", "lubMin"
        method.add_parameter "int", "lubMax"
        method.add_parameter "int", "cardMin"
        method.add_parameter "int", "cardMax"
      end
      
      klass.add_constructor do |method|
        method.add_parameter "Gecode::MSpace*", "home"
        method.add_parameter "Gecode::IntSet", "glbD"
        method.add_parameter "int", "lubMin"
        method.add_parameter "int", "lubMax"
        method.add_parameter "int", "cardMin", true
        method.add_parameter "int", "cardMax", true
      end
      
      klass.add_constructor do |method|
        method.add_parameter "Gecode::MSpace*", "home"
        method.add_parameter "int", "glbMin"
        method.add_parameter "int", "glbMax"
        method.add_parameter "Gecode::IntSet", "lubD"
        method.add_parameter "int", "cardMin", true
        method.add_parameter "int", "cardMax", true
      end
      
      klass.add_constructor do |method|
        method.add_parameter "Gecode::MSpace*", "home"
        method.add_parameter "Gecode::IntSet", "glbD"
        method.add_parameter "Gecode::IntSet", "lubD"
        method.add_parameter "int", "cardMin", true
        method.add_parameter "int", "cardMax", true
      end
      
      klass.add_method "glbSize", "int"
      klass.add_method "lubSize", "int"
      klass.add_method "unknownSize", "int"
      klass.add_method "cardMin", "int"
      klass.add_method "cardMax", "int"
      klass.add_method "lubMin", "int"
      klass.add_method "lubMax", "int"
      klass.add_method "glbMin", "int"
      klass.add_method "glbMax", "int"
      klass.add_method "glbSize", "int"
      klass.add_method "contains", "bool" do |method|
        method.add_parameter "int", "i"
      end
      
      klass.add_method "notContains", "bool" do |method|
        method.add_parameter "int", "i"
      end
      
      klass.add_method "assigned", "bool"
      
      klass.add_method "update" do |method|
        method.add_parameter "Gecode::MSpace *", "home"
        method.add_parameter "bool", "shared"
        method.add_parameter "Gecode::SetVar", "x"
      end
    end
    
    ns.add_cxx_class "MDFS" do |klass|
      klass.bindname = "DFS"
      klass.add_constructor do |method|
        method.add_parameter "Gecode::MSpace *", "s"
        method.add_parameter "int", "c_d"
        method.add_parameter "int", "a_d"
        method.add_parameter "Gecode::Search::MStop *", "st"
      end
      
      klass.add_method "next", "Gecode::MSpace *"
      klass.add_method "statistics", "Gecode::Search::Statistics"
    end
    
    # SEARCH NAMESPACE
    
    ns.add_namespace "Search" do |searchns|
      searchns.add_cxx_class "MStop" do |klass|
        klass.bindname = "Stop"
        klass.add_constructor
      end
      
      searchns.add_cxx_class "Statistics" do |klass|
        klass.add_constructor
        klass.add_attribute "memory", "int"
        klass.add_attribute "propagate", "int"
        klass.add_attribute "fail", "int"
        klass.add_attribute "clone", "int"
        klass.add_attribute "commit", "int"
      end
    end
    
    # MINIMODEL NAMESPACE
    
    ns.add_namespace "MiniModel" do |minimodelns|
      minimodelns.add_cxx_class "LinExpr" do |klass|
        klass.add_constructor
        
        klass.add_method "post" do |method|
          method.add_parameter "Gecode::MSpace *", "home"
          method.add_parameter "Gecode::IntRelType", "irt"
          method.add_parameter "Gecode::IntConLevel", "icl"
        end
        
        klass.add_method "post" do |method|
          method.add_parameter "Gecode::MSpace *", "home"
          method.add_parameter "Gecode::IntRelType", "irt"
          method.add_parameter "Gecode::BoolVar", "b"
        end
        
        klass.add_operator "+", "Gecode::MiniModel::LinExpr" do |operator|
          operator.add_parameter("Gecode::MiniModel::LinExpr", "exp")
        end
        
        klass.add_operator "+", "Gecode::MiniModel::LinExpr" do |operator|
          operator.add_parameter("Gecode::IntVar", "exp")
        end
        
        klass.add_operator "+", "Gecode::MiniModel::LinExpr" do |operator|
          operator.add_parameter("int", "c")
        end
        
        klass.add_operator "-", "Gecode::MiniModel::LinExpr" do |operator|
          operator.add_parameter("Gecode::MiniModel::LinExpr", "exp")
        end
        
        klass.add_operator "-", "Gecode::MiniModel::LinExpr" do |operator|
          operator.add_parameter("Gecode::IntVar", "exp")
        end
        
        klass.add_operator "-", "Gecode::MiniModel::LinExpr" do |operator|
          operator.add_parameter("int", "c")
        end
        
        klass.add_operator "*", "Gecode::MiniModel::LinExpr" do |operator|
          operator.add_parameter("int", "c")
        end
        
        klass.add_operator "==", "Gecode::MiniModel::LinRel", "equal" do |operator|
          operator.add_parameter "Gecode::MiniModel::LinExpr", "other"
        end
        
        klass.add_operator "!=", "Gecode::MiniModel::LinRel", "different" do |operator|
          operator.add_parameter "Gecode::MiniModel::LinExpr", "other"
        end
      end
      
      minimodelns.add_cxx_class "BoolExpr" do |klass| # TODO
        klass.add_enum "NodeType" do |enum|
          enum.add_value "BT_VAR"
          enum.add_value "BT_NOT"
          enum.add_value "BT_AND"
          enum.add_value "BT_OR"
          enum.add_value "BT_IMP"
          enum.add_value "BT_XOR"
          enum.add_value "BT_EQV"
          enum.add_value "BT_RLIN"
        end
        klass.add_constructor do |method|
          method.add_parameter "Gecode::MiniModel::BoolExpr", "e"
        end
        
        klass.add_constructor do |method|
          method.add_parameter "Gecode::BoolVar", "e"
        end
        
        klass.add_constructor do |method|
          method.add_parameter "Gecode::MiniModel::BoolExpr", "l"
          method.add_parameter "Gecode::MiniModel::BoolExpr::NodeType", "t"
          method.add_parameter "Gecode::MiniModel::BoolExpr", "r"
        end
        
        klass.add_constructor do |method|
          method.add_parameter "Gecode::MiniModel::BoolExpr", "l"
          method.add_parameter "Gecode::MiniModel::BoolExpr::NodeType", "t"
        end
        
        klass.add_constructor do |method|
          method.add_parameter "Gecode::MiniModel::LinRel", "e"
        end
        
        klass.add_method "post" do |method|
          method.add_parameter "Gecode::MSpace *", "home"
        end
        
        klass.add_method "post" do |method|
          method.add_parameter "Gecode::MSpace *", "home"
          method.add_parameter "bool", "t"
        end
      end
      
      minimodelns.add_cxx_class "BoolRel" do |klass|
        klass.add_constructor do |method|
          method.add_parameter "Gecode::MiniModel::BoolExpr", "e"
          method.add_parameter "bool", "t"
        end
      end
      
      minimodelns.add_cxx_class "LinRel" do |klass|
        klass.add_constructor
        
        klass.add_constructor do |method|
          method.add_parameter "Gecode::MiniModel::LinExpr", "l"
          method.add_parameter "Gecode::IntRelType", "irt"
          method.add_parameter "Gecode::MiniModel::LinExpr", "r"
        end
        
        klass.add_constructor do |method|
          method.add_parameter "Gecode::MiniModel::LinExpr", "l"
          method.add_parameter "Gecode::IntRelType", "irt"
          method.add_parameter "int", "r"
        end
        
        klass.add_constructor do |method|
          method.add_parameter "int", "l"
          method.add_parameter "Gecode::IntRelType", "irt"
          method.add_parameter "Gecode::MiniModel::LinExpr", "r"
        end
        
        klass.add_method "post", "void" do |method|
          method.add_parameter "Gecode::MSpace*", "home"
          method.add_parameter "bool", "t"
          method.add_parameter "Gecode::IntConLevel", "icl"
        end
        klass.add_method "post", "void" do |method|
          method.add_parameter "Gecode::MSpace*", "home"
          method.add_parameter "Gecode::BoolVar", "b"
        end
        
# 				klass.add_operator "==", "Gecode::MiniModel::LinRel", "equal" do |operator|
# 					operator.add_parameter "int", "i"
# 				end
      end
    end
    
    
    
    # INT POSTING FUNCTIONS
    
    ns.add_function "abs" do |func|
      func.add_parameter "Gecode::MSpace *", "home"
      func.add_parameter "Gecode::IntVar", "x0"
      func.add_parameter "Gecode::IntVar", "x1"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "max" do |func|
      func.add_parameter "Gecode::MSpace *", "home"
      func.add_parameter "Gecode::IntVar", "x0"
      func.add_parameter "Gecode::IntVar", "x1"
      func.add_parameter "Gecode::IntVar", "x2"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "max" do |func|
      func.add_parameter "Gecode::MSpace *", "home"
      func.add_parameter "Gecode::MIntVarArray", "arr" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 1)->ptr()"
      end
      func.add_parameter "Gecode::IntVar", "y"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "min" do |func|
      func.add_parameter "Gecode::MSpace *", "home"
      func.add_parameter "Gecode::IntVar", "x0"
      func.add_parameter "Gecode::IntVar", "x1"
      func.add_parameter "Gecode::IntVar", "x2"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "min" do |func|
      func.add_parameter "Gecode::MSpace *", "home"
      func.add_parameter "Gecode::MIntVarArray", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 1)->ptr()"
      end
      func.add_parameter "Gecode::IntVar", "y"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "mult" do |func|
      func.add_parameter "Gecode::MSpace *", "home"
      func.add_parameter "Gecode::IntVar", "x0"
      func.add_parameter "Gecode::IntVar", "x1"
      func.add_parameter "Gecode::IntVar", "x2"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    # Bool post functions
    
    ns.add_function "bool_not" do |func|
      func.add_parameter "Gecode::MSpace *", "home"
      func.add_parameter "Gecode::BoolVar", "b0"
      func.add_parameter "Gecode::BoolVar", "b1"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "bool_eq" do |func|
      func.add_parameter "Gecode::MSpace *", "home"
      func.add_parameter "Gecode::BoolVar", "b0"
      func.add_parameter "Gecode::BoolVar", "b1"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "bool_and" do |func|
      func.add_parameter "Gecode::MSpace *", "home"
      func.add_parameter "Gecode::BoolVar", "b0"
      func.add_parameter "Gecode::BoolVar", "b1"
      func.add_parameter "Gecode::BoolVar", "b2"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "bool_and" do |func|
      func.add_parameter "Gecode::MSpace *", "home"
      func.add_parameter "Gecode::BoolVar", "b0"
      func.add_parameter "Gecode::BoolVar", "b1"
      func.add_parameter "bool", "b2"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "bool_and" do |func|
      func.add_parameter "Gecode::MSpace *", "home"
      func.add_parameter "Gecode::MBoolVarArray", "b0" do |param|
        param.custom_conversion = "*reinterpret_cast<Gecode::BoolVarArgs *>(ruby2Gecode_MBoolVarArrayPtr(argv[1], 1)->ptr())"
      end
      func.add_parameter "Gecode::BoolVar", "c"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "bool_and" do |func|
      func.add_parameter "Gecode::MSpace *", "home"
      func.add_parameter "Gecode::MBoolVarArray", "b0" do |param|
        param.custom_conversion = "*reinterpret_cast<Gecode::BoolVarArgs *>(ruby2Gecode_MBoolVarArrayPtr(argv[1], 1)->ptr())"
      end
      func.add_parameter "bool", "c"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "bool_or" do |func|
      func.add_parameter "Gecode::MSpace *", "home"
      func.add_parameter "Gecode::BoolVar", "b0"
      func.add_parameter "Gecode::BoolVar", "b1"
      func.add_parameter "Gecode::BoolVar", "b2"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "bool_or" do |func|
      func.add_parameter "Gecode::MSpace *", "home"
      func.add_parameter "Gecode::BoolVar", "b0"
      func.add_parameter "Gecode::BoolVar", "b1"
      func.add_parameter "bool", "b2"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "bool_or" do |func|
      func.add_parameter "Gecode::MSpace *", "home"
      func.add_parameter "Gecode::MBoolVarArray", "b" do |param|
        param.custom_conversion = "*reinterpret_cast<Gecode::BoolVarArgs *>(ruby2Gecode_MBoolVarArrayPtr(argv[1], 2)->ptr())"
      end
      func.add_parameter "Gecode::BoolVar", "c"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "bool_or" do |func|
      func.add_parameter "Gecode::MSpace *", "home"
      func.add_parameter "Gecode::MBoolVarArray", "b" do |param|
        param.custom_conversion = "*reinterpret_cast<Gecode::BoolVarArgs *>(ruby2Gecode_MBoolVarArrayPtr(argv[1], 2)->ptr())"
      end
      func.add_parameter "bool", "c"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "bool_imp" do |func|
      func.add_parameter "Gecode::MSpace *", "home"
      func.add_parameter "Gecode::BoolVar", "b0"
      func.add_parameter "Gecode::BoolVar", "b1"
      func.add_parameter "Gecode::BoolVar", "b2"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "bool_imp" do |func|
      func.add_parameter "Gecode::MSpace *", "home"
      func.add_parameter "Gecode::BoolVar", "b0"
      func.add_parameter "Gecode::BoolVar", "b1"
      func.add_parameter "bool", "b2"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "bool_eqv" do |func|
      func.add_parameter "Gecode::MSpace *", "home"
      func.add_parameter "Gecode::BoolVar", "b0"
      func.add_parameter "Gecode::BoolVar", "b1"
      func.add_parameter "Gecode::BoolVar", "b2"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "bool_eqv" do |func|
      func.add_parameter "Gecode::MSpace *", "home"
      func.add_parameter "Gecode::BoolVar", "b0"
      func.add_parameter "Gecode::BoolVar", "b1"
      func.add_parameter "bool", "b2"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "bool_xor" do |func|
      func.add_parameter "Gecode::MSpace *", "home"
      func.add_parameter "Gecode::BoolVar", "b0"
      func.add_parameter "Gecode::BoolVar", "b1"
      func.add_parameter "Gecode::BoolVar", "b2"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "bool_xor" do |func|
      func.add_parameter "Gecode::MSpace *", "home"
      func.add_parameter "Gecode::BoolVar", "b0"
      func.add_parameter "Gecode::BoolVar", "b1"
      func.add_parameter "bool", "b2"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    # 
    
    ns.add_function "branch" do |func|
      func.add_parameter "Gecode::MSpace *", "home"
      func.add_parameter "Gecode::MIntVarArray *", "iva" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "Gecode::BvarSel", "vars"
      func.add_parameter "Gecode::BvalSel", "vals"
    end
    
    ns.add_function "branch" do |func|
      func.add_parameter "Gecode::MSpace *", "home"
      func.add_parameter "Gecode::MBoolVarArray *", "iva" do |param|
        param.custom_conversion = "*ruby2Gecode_MBoolVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "Gecode::BvarSel", "vars"
      func.add_parameter "Gecode::BvalSel", "vals"
    end
    
    ns.add_function "branch" do |func|
      func.add_parameter "Gecode::MSpace *", "home"
      func.add_parameter "Gecode::MSetVarArray *", "sva" do |param|
        param.custom_conversion = "*ruby2Gecode_MSetVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "Gecode::SetBvarSel", "vars"
      func.add_parameter "Gecode::SetBvalSel", "vals"
    end
    
    ns.add_function "assign" do |func|
      func.add_parameter "Gecode::MSpace *", "home"
      func.add_parameter "Gecode::MIntVarArray *", "iva" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(iva, 1)->ptr()"
      end
      func.add_parameter "Gecode::AvalSel", "vals"
    end
    
    ns.add_function "channel" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MIntVarArray *", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "Gecode::MIntVarArray *", "y" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[2], 3)->ptr()"
      end
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "count" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MIntVarArray *", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      
      func.add_parameter "int", "y"
      func.add_parameter "Gecode::IntRelType", "r"
      func.add_parameter "int", "m"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "count" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MIntVarArray *", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      
      func.add_parameter "Gecode::IntVar", "y"
      func.add_parameter "Gecode::IntRelType", "r"
      func.add_parameter "int", "m"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "count" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MIntVarArray *", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      
      func.add_parameter "int", "y"
      func.add_parameter "Gecode::IntRelType", "r"
      func.add_parameter "Gecode::IntVar", "m"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "count" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MIntVarArray *", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      
      func.add_parameter "Gecode::IntVar", "y"
      func.add_parameter "Gecode::IntRelType", "r"
      func.add_parameter "Gecode::IntVar", "m"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    
    ns.add_function "cumulatives", "void" do |method|
      method.add_parameter "Gecode::MSpace*", "home"
      method.add_parameter "Gecode::IntArgs&", "machine" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      method.add_parameter "Gecode::MIntVarArray", "start" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[2], 3)->ptr()"
      end
      method.add_parameter "Gecode::MIntVarArray", "duration" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[3], 4)->ptr()"
      end
      method.add_parameter "Gecode::MIntVarArray", "end" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[4], 5)->ptr()"
      end
      method.add_parameter "Gecode::MIntVarArray", "height" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[5], 6)->ptr()"
      end
      method.add_parameter "Gecode::IntArgs&", "limit"
      method.add_parameter "bool", "at_most"
      method.add_parameter "Gecode::IntConLevel", "icl", true
    end

    ns.add_function "cumulatives", "void" do |method|
      method.add_parameter "Gecode::MSpace*", "home"
      method.add_parameter "Gecode::IntArgs&", "machine" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      method.add_parameter "Gecode::MIntVarArray", "start" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[2], 3)->ptr()"
      end
      method.add_parameter "Gecode::IntArgs&", "duration"
      method.add_parameter "Gecode::MIntVarArray", "end" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[4], 5)->ptr()"
      end
      method.add_parameter "Gecode::MIntVarArray", "height" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[5], 6)->ptr()"
      end
      method.add_parameter "Gecode::IntArgs&", "limit"
      method.add_parameter "bool", "at_most"
      method.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "cumulatives", "void" do |method|
      method.add_parameter "Gecode::MSpace*", "home"
      method.add_parameter "Gecode::IntArgs&", "machine"
      method.add_parameter "Gecode::MIntVarArray", "start" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[2], 3)->ptr()"
      end
      method.add_parameter "Gecode::IntArgs&", "duration"
      method.add_parameter "Gecode::MIntVarArray", "end" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[4], 5)->ptr()"
      end
      method.add_parameter "Gecode::MIntVarArray", "height" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[5], 6)->ptr()"
      end
      method.add_parameter "Gecode::IntArgs&", "limit"
      method.add_parameter "bool", "at_most"
      method.add_parameter "Gecode::IntConLevel", "icl", true
    end

    ns.add_function "cumulatives", "void" do |method|
      method.add_parameter "Gecode::MSpace*", "home"
      method.add_parameter "Gecode::IntArgs&", "machine" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      method.add_parameter "Gecode::MIntVarArray", "start" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[2], 3)->ptr()"
      end
      method.add_parameter "Gecode::MIntVarArray", "duration" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[3], 4)->ptr()"
      end
      method.add_parameter "Gecode::MIntVarArray", "end" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[4], 5)->ptr()"
      end
      method.add_parameter "Gecode::IntArgs&", "height"
      method.add_parameter "Gecode::IntArgs&", "limit"
      method.add_parameter "bool", "at_most"
      method.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "cumulatives", "void" do |method|
      method.add_parameter "Gecode::MSpace*", "home"
      method.add_parameter "Gecode::IntArgs&", "machine"
      method.add_parameter "Gecode::MIntVarArray", "start" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[2], 3)->ptr()"
      end
      method.add_parameter "Gecode::MIntVarArray", "duration" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[3], 4)->ptr()"
      end
      method.add_parameter "Gecode::MIntVarArray", "end" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[4], 5)->ptr()"
      end
      method.add_parameter "Gecode::IntArgs&", "height"
      method.add_parameter "Gecode::IntArgs&", "limit"
      method.add_parameter "bool", "at_most"
      method.add_parameter "Gecode::IntConLevel", "icl"
    end
    
    ns.add_function "cumulatives", "void" do |method|
      method.add_parameter "Gecode::MSpace*", "home"
      method.add_parameter "Gecode::IntArgs&", "machine" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      method.add_parameter "Gecode::MIntVarArray", "start" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[2], 3)->ptr()"
      end
      method.add_parameter "Gecode::IntArgs&", "duration"
      method.add_parameter "Gecode::MIntVarArray", "end" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[4], 5)->ptr()"
      end
      method.add_parameter "Gecode::IntArgs&", "height"
      method.add_parameter "Gecode::IntArgs&", "limit"
      method.add_parameter "bool", "at_most"
      method.add_parameter "Gecode::IntConLevel", "icl"
    end
    
    ns.add_function "cumulatives", "void" do |method|
      method.add_parameter "Gecode::MSpace*", "home"
      method.add_parameter "Gecode::IntArgs&", "machine"
      method.add_parameter "Gecode::MIntVarArray", "start" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[2], 3)->ptr()"
      end
      method.add_parameter "Gecode::IntArgs&", "duration"
      method.add_parameter "Gecode::MIntVarArray", "end" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[4], 5)->ptr()"
      end
      method.add_parameter "Gecode::IntArgs&", "height"
      method.add_parameter "Gecode::IntArgs&", "limit"
      method.add_parameter "bool", "at_most"
      method.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "distinct" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MIntVarArray *", "iva" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "distinct" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::IntArgs", "x"
      func.add_parameter "Gecode::MIntVarArray *", "iva" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[2], 3)->ptr()"
      end
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    
    ns.add_function "dom" do |func|
      func.add_parameter  "Gecode::MSpace*", "home"
      func.add_parameter  "Gecode::IntVar", "x"
      func.add_parameter  "int", "l"
      func.add_parameter  "int", "m"
      func.add_parameter  "Gecode::IntConLevel", "icl"
    end
    
    ns.add_function "dom" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MIntVarArray *", "iva" do |param|
        param.custom_conversion = "*reinterpret_cast<Gecode::IntVarArgs *>(ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr())"
      end
      func.add_parameter "int", "l"
      func.add_parameter "int", "m"
      func.add_parameter "Gecode::IntConLevel", "icl"
    end
    
    ns.add_function "dom" do |func|
      func.add_parameter  "Gecode::MSpace*", "home"
      func.add_parameter  "Gecode::IntVar", "x"
      func.add_parameter  "Gecode::IntSet", "s"
      func.add_parameter  "Gecode::IntConLevel", "icl"
    end
    
    ns.add_function "dom" do |func|
      func.add_parameter  "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MIntVarArray *", "iva" do |param|
        param.custom_conversion = "*reinterpret_cast<Gecode::IntVarArgs *>(ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr())"
      end
      func.add_parameter  "Gecode::IntSet", "s"
      func.add_parameter  "Gecode::IntConLevel", "icl"
    end
    
    ns.add_function "dom" do |func|
      func.add_parameter  "Gecode::MSpace*", "home"
      func.add_parameter  "Gecode::IntVar", "x"
      func.add_parameter  "int", "l"
      func.add_parameter  "int", "m"
      func.add_parameter  "Gecode::BoolVar", "b"
      func.add_parameter  "Gecode::IntConLevel", "icl"
    end
    
    ns.add_function "dom" do |func|
      func.add_parameter  "Gecode::MSpace*", "home"
      func.add_parameter  "Gecode::IntVar", "x"
      func.add_parameter  "Gecode::IntSet", "s"
      func.add_parameter  "Gecode::BoolVar", "b"
      func.add_parameter  "Gecode::IntConLevel", "icl"
    end
    
    ns.add_function "element", "void" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::IntArgs&", "x"
      func.add_parameter "Gecode::IntVar", "y0"
      func.add_parameter "Gecode::IntVar", "y1"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "element", "void" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MIntVarArray *", "iva" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "Gecode::IntVar", "y0"
      func.add_parameter "Gecode::IntVar", "y1"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "gcc", "void" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MIntVarArray *", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "Gecode::IntArgs", "c"
      func.add_parameter "int", "m"
      func.add_parameter "int", "unspec_low"
      func.add_parameter "int", "unspec_up"
      func.add_parameter "int", "min"
      func.add_parameter "int", "max"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "gcc", "void" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MIntVarArray *", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "Gecode::IntArgs", "c"
      func.add_parameter "int", "m"
      func.add_parameter "int", "unspec"
      func.add_parameter "int", "min"
      func.add_parameter "int", "max"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "gcc", "void" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MIntVarArray *", "x" do |param|
        param.custom_conversion = "*reinterpret_cast<Gecode::IntVarArgs *>(ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr())"
      end
      func.add_parameter "int", "lb"
      func.add_parameter "int", "ub"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "gcc", "void" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MIntVarArray *", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "int", "ub"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "gcc", "void" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MIntVarArray *", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "Gecode::MIntVarArray *", "c" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[2], 3)->ptr()"
      end
      func.add_parameter "int", "min"
      func.add_parameter "int", "max"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "gcc", "void" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MIntVarArray *", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "Gecode::IntArgs", "v"
      func.add_parameter "Gecode::MIntVarArray *", "c" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[3], 4)->ptr()"
      end
      func.add_parameter "int", "m"
      func.add_parameter "int", "unspec"
      func.add_parameter "bool", "all"
      func.add_parameter "int", "min"
      func.add_parameter "int", "max"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "linear", "void" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MIntVarArray *", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "Gecode::IntRelType", "r"
      func.add_parameter "int", "c"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    ns.add_function "linear", "void" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MIntVarArray *", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "Gecode::IntRelType", "r"
      func.add_parameter "int", "c"
      func.add_parameter "Gecode::BoolVar", "b"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "linear", "void" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::IntArgs", "a"
      func.add_parameter "Gecode::MIntVarArray *", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[2], 3)->ptr()"
      end
      func.add_parameter "Gecode::IntRelType", "r"
      func.add_parameter "int", "c"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "linear", "void" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::IntArgs", "a"
      func.add_parameter "Gecode::MIntVarArray *", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[2], 3)->ptr()"
      end
      func.add_parameter "Gecode::IntRelType", "r"
      func.add_parameter "int", "c"
      func.add_parameter "Gecode::BoolVar", "b"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "linear", "void" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MIntVarArray *", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "Gecode::IntRelType", "r"
      func.add_parameter "Gecode::IntVar", "c"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "linear", "void" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MIntVarArray *", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "Gecode::IntRelType", "r"
      func.add_parameter "Gecode::IntVar", "c"
      func.add_parameter "Gecode::BoolVar", "b"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    
    ns.add_function "linear", "void" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::IntArgs", "a"
      func.add_parameter "Gecode::MIntVarArray *", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[2], 3)->ptr()"
      end
      func.add_parameter "Gecode::IntRelType", "r"
      func.add_parameter "Gecode::IntVar", "y"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "linear", "void" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::IntArgs", "a"
      func.add_parameter "Gecode::MIntVarArray *", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[2], 3)->ptr()"
      end
      func.add_parameter "Gecode::IntRelType", "r"
      func.add_parameter "Gecode::IntVar", "y"
      func.add_parameter "Gecode::BoolVar", "b"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "linear", "void" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MBoolVarArray *", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MBoolVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "Gecode::IntRelType", "r"
      func.add_parameter "int", "y"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "linear", "void" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MBoolVarArray *", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MBoolVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "Gecode::IntRelType", "r"
      func.add_parameter "Gecode::IntVar", "y"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
# 		ns.add_function "regular", "void" do |func|
# 			func.add_parameter "Gecode::MSpace*", "home"
# 			func.add_parameter "Gecode::MIntVarArray *", "x" do |param|
# 				param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
# 			end
# 			func.add_parameter "Gecode::DFA", "dfa" # TODO: add class DFA
# 			func.add_parameter "Gecode::IntConLevel", "icl", true
# 		end
    
    ns.add_function "rel" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::IntVar", "x0"
      func.add_parameter "Gecode::IntRelType", "r"
      func.add_parameter "int", "c"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "rel" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::IntVar", "x0"
      func.add_parameter "Gecode::IntRelType", "r"
      func.add_parameter "Gecode::IntVar", "x1"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "rel" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::IntVar", "x0"
      func.add_parameter "Gecode::IntRelType", "r"
      func.add_parameter "Gecode::IntVar", "x1"
      func.add_parameter "Gecode::BoolVar", "b"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "rel" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::IntVar", "x0"
      func.add_parameter "Gecode::IntRelType", "r"
      func.add_parameter "int", "c"
      func.add_parameter "Gecode::BoolVar", "b"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "rel" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MBoolVarArray *", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "Gecode::IntRelType", "r"
      func.add_parameter "Gecode::MIntVarArray *", "y" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[3], 4)->ptr()"
      end
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "eq", "void" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::IntVar", "x1"
      func.add_parameter "Gecode::IntVar", "x2"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "eq", "void" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::IntVar", "x"
      func.add_parameter "int", "n"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "eq", "void" do |method|
      method.add_parameter "Gecode::MSpace*", "home"
      method.add_parameter "Gecode::IntVar", "x0"
      method.add_parameter "Gecode::IntVar", "x1"
      method.add_parameter "Gecode::BoolVar", "b"
      method.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "eq", "void" do |method|
      method.add_parameter "Gecode::MSpace*", "home"
      method.add_parameter "Gecode::IntVar", "x"
      method.add_parameter "int", "n"
      method.add_parameter "Gecode::BoolVar", "b"
      method.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "eq", "void" do |method|
      method.add_parameter "Gecode::MSpace*", "home"
      method.add_parameter "Gecode::MIntVarArray *", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      method.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "sortedness", "void" do |method|
      method.add_parameter "Gecode::MSpace*", "home"
      method.add_parameter "Gecode::MIntVarArray *", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      method.add_parameter "Gecode::MIntVarArray *", "y" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[2], 3)->ptr()"
      end
      method.add_parameter "Gecode::IntConLevel", "icl", true
    end
    ns.add_function "sortedness", "void" do |method|
      method.add_parameter "Gecode::MSpace*", "home"
      method.add_parameter "Gecode::MIntVarArray *", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      method.add_parameter "Gecode::MIntVarArray *", "y" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[2], 3)->ptr()"
      end
      method.add_parameter "Gecode::MIntVarArray *", "z" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[3], 4)->ptr()"
      end
      method.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "post", "Gecode::BoolVar" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MiniModel::BoolExpr", "e"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "post", "Gecode::BoolVar" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::BoolVar", "e"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "post" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MiniModel::BoolRel", "r"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "post", "Gecode::IntVar" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::IntVar", "e"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "post", "Gecode::IntVar" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "int", "n"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "post", "Gecode::IntVar" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MiniModel::LinExpr", "e"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "post" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MiniModel::LinRel", "e"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "post" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "bool", "r"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "producer_consumer" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MIntVarArray *", "produce_date" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "Gecode::IntArgs", "produce_amount"
      func.add_parameter "Gecode::MIntVarArray *", "consume_date" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[3], 4)->ptr()"
      end
      func.add_parameter "Gecode::IntArgs", "consume_amount"
      func.add_parameter "int", "initial"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "cumulative" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MIntVarArray *", "start" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "Gecode::MIntVarArray *", "duration" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "Gecode::MIntVarArray *", "height" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "int", "limit"
      func.add_parameter "bool", "at_most", true
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "cumulative" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MIntVarArray *", "start" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "Gecode::IntArgs", "duration"
      func.add_parameter "Gecode::MIntVarArray *", "height" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "int", "limit"
      func.add_parameter "bool", "at_most", true
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "cumulative" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MIntVarArray *", "start" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "Gecode::MIntVarArray *", "duration" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "Gecode::IntArgs", "height"
      func.add_parameter "int", "limit"
      func.add_parameter "bool", "at_most", true
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "cumulative" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MIntVarArray *", "start" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "Gecode::IntArgs", "duration"
      func.add_parameter "Gecode::IntArgs", "height"
      func.add_parameter "int", "limit"
      func.add_parameter "bool", "at_most", true
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "serialized" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MIntVarArray *", "start" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "Gecode::MIntVarArray *", "duration" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "serialized" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MIntVarArray *", "start" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "Gecode::IntArgs", "duration"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "atmost" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MIntVarArray *", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "int", "n"
      func.add_parameter "int", "m"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "atmost" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MIntVarArray *", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "Gecode::IntVar", "n"
      func.add_parameter "int", "m"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "atmost" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MIntVarArray *", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "int", "n"
      func.add_parameter "Gecode::IntVar", "m"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "atmost" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MIntVarArray *", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "Gecode::IntVar", "n"
      func.add_parameter "Gecode::IntVar", "m"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "atleast" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MIntVarArray *", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "int", "n"
      func.add_parameter "int", "m"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "atleast" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MIntVarArray *", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "Gecode::IntVar", "n"
      func.add_parameter "int", "m"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "atleast" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MIntVarArray *", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "int", "n"
      func.add_parameter "Gecode::IntVar", "m"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "atleast" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MIntVarArray *", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "Gecode::IntVar", "n"
      func.add_parameter "Gecode::IntVar", "m"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "exactly" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MIntVarArray *", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "int", "n"
      func.add_parameter "int", "m"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "exactly" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MIntVarArray *", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "Gecode::IntVar", "n"
      func.add_parameter "int", "m"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "exactly" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MIntVarArray *", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "int", "n"
      func.add_parameter "Gecode::IntVar", "m"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "exactly" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MIntVarArray *", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "Gecode::IntVar", "n"
      func.add_parameter "Gecode::IntVar", "m"
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "lex" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MIntVarArray *", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "Gecode::IntRelType", "r"
      func.add_parameter "Gecode::MIntVarArray *", "y" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[3], 4)->ptr()"
      end
      func.add_parameter "Gecode::IntConLevel", "icl", true
    end
    
    ns.add_function "cardinality" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::SetVar", "x"
      func.add_parameter "int", "i"
      func.add_parameter "int", "j"
    end
    
    ns.add_function "cardinality" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::SetVar", "s"
      func.add_parameter "Gecode::IntVar", "x"
    end
    
    ns.add_function "convex" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::SetVar", "s"
    end
    
    ns.add_function "convexHull" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::SetVar", "x"
      func.add_parameter "Gecode::SetVar", "y"
    end
    
    ns.add_function "atmostOne" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MSetVarArray", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MSetVarArrayPtr(x, 2)->ptr()"
      end
      func.add_parameter "int", "c"
    end
    
    ns.add_function "distinct" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MSetVarArray", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MSetVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "int", "c"
    end
    
    ns.add_function "dom" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::SetVar", "x"
      func.add_parameter "Gecode::SetRelType", "r"
      func.add_parameter "int", "i"
    end
    
    ns.add_function "dom" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::SetVar", "x"
      func.add_parameter "Gecode::SetRelType", "r"
      func.add_parameter "int", "i"
      func.add_parameter "int", "j"
    end
    
    
    ns.add_function "dom" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::SetVar", "x"
      func.add_parameter "Gecode::SetRelType", "r"
      func.add_parameter "Gecode::IntSet", "s"
    end
    
    ns.add_function "dom" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::SetVar", "x"
      func.add_parameter "Gecode::SetRelType", "r"
      func.add_parameter "int", "i"
      func.add_parameter "Gecode::BoolVar", "b"
    end
    
    ns.add_function "dom" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::SetVar", "x"
      func.add_parameter "Gecode::SetRelType", "r"
      func.add_parameter "int", "i"
      func.add_parameter "int", "j"
      func.add_parameter "Gecode::BoolVar", "b"
    end
    
    ns.add_function "dom" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::SetVar", "x"
      func.add_parameter "Gecode::SetRelType", "r"
      func.add_parameter "Gecode::IntSet", "s"
      func.add_parameter "Gecode::BoolVar", "b"
    end
    
    ns.add_function "rel" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::SetVar", "s"
      func.add_parameter "Gecode::IntRelType", "r"
      func.add_parameter "Gecode::IntVar", "x"
    end
    
    ns.add_function "rel" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::IntVar", "x"
      func.add_parameter "Gecode::IntRelType", "r"
      func.add_parameter "Gecode::SetVar", "s"
    end
    
    ns.add_function "min" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::SetVar", "s"
      func.add_parameter "Gecode::IntVar", "x"
    end
    
    ns.add_function "max" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::SetVar", "s"
      func.add_parameter "Gecode::IntVar", "x"
    end
    
    ns.add_function "match" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::SetVar", "s"
      func.add_parameter "Gecode::MIntVarArray", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(x, 3)->ptr()"
      end
    end
    
    ns.add_function "channel" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MIntVarArray", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[1], 2)->ptr()"
      end
      func.add_parameter "Gecode::MSetVarArray", "y" do |param|
        param.custom_conversion = "*ruby2Gecode_MSetVarArrayPtr(argv[2], 3)->ptr()"
      end
    end
    
    ns.add_function "weights" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::IntArgs", "elements"
      func.add_parameter "Gecode::IntArgs", "weights"
      func.add_parameter "Gecode::SetVar", "x"
      func.add_parameter "Gecode::IntVar", "y"
    end
    
    ns.add_function "rel" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::IntSet", "x"
      func.add_parameter "Gecode::SetOpType", "op"
      func.add_parameter "Gecode::SetVar", "y"
      func.add_parameter "Gecode::SetRelType", "r"
      func.add_parameter "Gecode::SetVar", "z"
    end
    
    ns.add_function "rel" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::SetVar", "x"
      func.add_parameter "Gecode::SetOpType", "op"
      func.add_parameter "Gecode::IntSet", "y"
      func.add_parameter "Gecode::SetRelType", "r"
      func.add_parameter "Gecode::SetVar", "z"
    end
    
    ns.add_function "rel" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::SetVar", "x"
      func.add_parameter "Gecode::SetOpType", "op"
      func.add_parameter "Gecode::SetVar", "y"
      func.add_parameter "Gecode::SetRelType", "r"
      func.add_parameter "Gecode::IntSet", "z"
    end
    
    ns.add_function "rel" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::IntSet", "x"
      func.add_parameter "Gecode::SetOpType", "op"
      func.add_parameter "Gecode::IntSet", "y"
      func.add_parameter "Gecode::SetRelType", "r"
      func.add_parameter "Gecode::SetVar", "z"
    end
    
    ns.add_function "rel" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::IntSet", "x"
      func.add_parameter "Gecode::SetOpType", "op"
      func.add_parameter "Gecode::SetVar", "y"
      func.add_parameter "Gecode::SetRelType", "r"
      func.add_parameter "Gecode::IntSet", "z"
    end
    
    ns.add_function "rel" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::SetVar", "x"
      func.add_parameter "Gecode::SetOpType", "op"
      func.add_parameter "Gecode::IntSet", "y"
      func.add_parameter "Gecode::SetRelType", "r"
      func.add_parameter "Gecode::IntSet", "z"
    end
    
    ns.add_function "rel" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::SetVar", "x"
      func.add_parameter "Gecode::SetOpType", "op"
      func.add_parameter "Gecode::SetVar", "y"
      func.add_parameter "Gecode::SetRelType", "r"
      func.add_parameter "Gecode::SetVar", "z"
    end
    
    
    ns.add_function "rel" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::SetOpType", "op"
      func.add_parameter "Gecode::MSetVarArray", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MSetVarArrayPtr(argv[2], 3)->ptr()"
      end
      func.add_parameter "Gecode::SetVar", "y"
    end
    
    ns.add_function "rel" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::SetOpType", "op"
      func.add_parameter "Gecode::MIntVarArray", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MIntVarArrayPtr(argv[2], 3)->ptr()"
      end
      func.add_parameter "Gecode::SetVar", "y"
    end
    
    ns.add_function "rel" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::SetVar", "x"
      func.add_parameter "Gecode::SetRelType", "r"
      func.add_parameter "Gecode::SetVar", "y"
    end
    
    ns.add_function "rel" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::SetVar", "x"
      func.add_parameter "Gecode::SetRelType", "r"
      func.add_parameter "Gecode::IntVar", "y"
    end
    
    ns.add_function "rel" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::IntVar", "x"
      func.add_parameter "Gecode::SetRelType", "r"
      func.add_parameter "Gecode::SetVar", "y"
    end
    
    ns.add_function "rel" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::SetVar", "x"
      func.add_parameter "Gecode::SetRelType", "r"
      func.add_parameter "Gecode::SetVar", "y"
      func.add_parameter "Gecode::BoolVar", "b"
    end
    
    ns.add_function "rel" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::SetVar", "x"
      func.add_parameter "Gecode::SetRelType", "r"
      func.add_parameter "Gecode::IntVar", "y"
      func.add_parameter "Gecode::BoolVar", "b"
    end
    
    ns.add_function "rel" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::IntVar", "x"
      func.add_parameter "Gecode::SetRelType", "r"
      func.add_parameter "Gecode::SetVar", "y"
      func.add_parameter "Gecode::BoolVar", "b"
    end
    
    ns.add_function "selectUnion" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MSetVarArray", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MSetVarArrayPtr(x, 2)->ptr()"
      end
      func.add_parameter "Gecode::SetVar", "y"
      func.add_parameter "Gecode::SetVar", "z"
    end
    
    ns.add_function "selectInter" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MSetVarArray", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MSetVarArrayPtr(x, 2)->ptr()"
      end
      func.add_parameter "Gecode::SetVar", "y"
      func.add_parameter "Gecode::SetVar", "z"
    end
    
    ns.add_function "selectInterIn" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MSetVarArray", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MSetVarArrayPtr(x, 2)->ptr()"
      end
      func.add_parameter "Gecode::SetVar", "y"
      func.add_parameter "Gecode::SetVar", "z"
      func.add_parameter "Gecode::IntSet", "universe"
    end
    
    ns.add_function "selectSet" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MSetVarArray", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MSetVarArrayPtr(x, 2)->ptr()"
      end
      func.add_parameter "Gecode::IntVar", "y"
      func.add_parameter "Gecode::SetVar", "z"
    end
    
    ns.add_function "selectDisjoint" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MSetVarArray", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MSetVarArrayPtr(x, 2)->ptr()"
      end
      func.add_parameter "Gecode::SetVar", "y"
    end
    
    ns.add_function "sequence" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MSetVarArray", "x" do |param|
        param.custom_conversion = "*ruby2Gecode_MSetVarArrayPtr(x, 2)->ptr()"
      end
    end
    
    ns.add_function "sequentialUnion" do |func|
      func.add_parameter "Gecode::MSpace*", "home"
      func.add_parameter "Gecode::MSetVarArray", "y" do |param|
        param.custom_conversion = "*ruby2Gecode_MSetVarArrayPtr(y, 2)->ptr()"
      end
      func.add_parameter "Gecode::SetVar", "x"
    end
  end
end
