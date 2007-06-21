module Gecode::Constraints::IntEnum
  class Expression
    # Posts a distinct constraint on the variables in the enum.
    def distinct(options = {})
      if @negate
        # The best we could implement it as from here would be a bunch of 
        # reified pairwise equality constraints. 
        raise Gecode::MissingConstraintError, 'A negated distinct is not ' + 
          'implemented.'
      end

      strength, reif = Gecode::Constraints::OptionUtil.decode_options(options)
      if reif.nil?
        Gecode::Raw::distinct(@space, @var_array, strength)
      else
        Gecode::Raw::distinct(@space, @var_array, strength, reif)
      end
    end
  end
end