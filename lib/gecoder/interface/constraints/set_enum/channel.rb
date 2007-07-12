module Gecode::Constraints::SetEnum
  class Expression
    # Posts a channel constraint on the variables in the enum with the specified
    # int enum.
    def channel(enum)
      unless enum.respond_to? :to_int_var_array
        raise TypeError, "Expected integer variable enum, for #{enum.class}."
      end
      
      # Just provide commutativity to the corresponding int enum constraint.
      if @params[:negate]
        enum.must_not.channel(@params[:lhs])
      else
        enum.must.channel(@params[:lhs])
      end
    end
  end
end