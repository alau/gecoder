module Gecode
  module IntEnumMethods
    include Gecode::Constraints::LeftHandSideMethods
    
    private
    
    # Produces an expression for the lhs module.
    def expression(params)
      params.update(:lhs => self)
      Constraints::IntEnum::Expression.new(@model, params)
    end
  end
  
  # A module containing constraints that have enumerations of integer 
  # variables as left hand side.
  module Constraints::IntEnum
    # Expressions with int enums as left hand sides.
    class Expression < Gecode::Constraints::Expression #:nodoc:
      # Raises TypeError unless the left hand side is an int enum.
      def initialize(model, params)
        super
        
        unless params[:lhs].respond_to? :to_int_var_array
          raise TypeError, 'Must have int enum as left hand side.'
        end
      end
    end
  end
end

require 'gecoder/interface/constraints/int_enum/distinct'
require 'gecoder/interface/constraints/int_enum/equality'
require 'gecoder/interface/constraints/int_enum/channel'
require 'gecoder/interface/constraints/int_enum/element'
require 'gecoder/interface/constraints/int_enum/count'
require 'gecoder/interface/constraints/int_enum/sort'
require 'gecoder/interface/constraints/int_enum/arithmetic'
