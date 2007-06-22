module Gecode
  module IntEnumMethods
    attr :distinct_offsets
  
    # Specified offsets to be used with a distinct constraint. The offsets can
    # be specified one by one or as an array of offsets.
    def with_offsets(*offsets)
      if offsets.kind_of? Enumerable
        @distinct_offsets = *offsets
      else
        @distinct_offsets = offsets
      end
      return self
    end
  end
end

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
      params = [@space, @var_array.distinct_offsets, 
        @var_array.to_int_var_array, strength, reif]
      params.delete_if{ |x| x.nil? }
      Gecode::Raw::distinct(*params)
    end
  end
end