module Gecode::Constraints::IntEnum
  class Expression
    # Posts a distinct constraint on the variables in the enum.
    def distinct
      if @negate
        # The best we could implement it as from here would be a bunch of 
        # reified pairwise equality constraints. 
        raise Gecode::MissingConstraintError, 'A negated distinct has not ' + 
          'been implemented.'
      end
      
      Gecode::Raw::distinct(@space, @var_array, Gecode::Raw::ICL_DEF)
    end
  end
end