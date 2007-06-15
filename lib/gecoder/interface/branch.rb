module Gecode
  class Model
    private
    
    # Maps the names of the supported variable branch strategies to the 
    # corresponding constant in Gecode. 
    BRANCH_VAR_CONSTANTS = {
      :none                 => Gecode::Raw::BVAR_NONE,
      :smallest_min         => Gecode::Raw::BVAR_MIN_MIN,
      :largest_min          => Gecode::Raw::BVAR_MIN_MAX, 
      :smallest_max         => Gecode::Raw::BVAR_MAX_MIN, 
      :largest_max          => Gecode::Raw::BVAR_MAX_MAX, 
      :smallest_size        => Gecode::Raw::BVAR_SIZE_MIN, 
      :largest_size         => Gecode::Raw::BVAR_SIZE_MAX,
      :smallest_degree      => Gecode::Raw::BVAR_DEGREE_MIN, 
      :largest_degree       => Gecode::Raw::BVAR_DEGREE_MAX, 
      :smallest_min_regret  => Gecode::Raw::BVAR_REGRET_MIN_MIN,
      :largest_min_regret   => Gecode::Raw::BVAR_REGRET_MIN_MAX,
      :smallest_max_regret  => Gecode::Raw::BVAR_REGRET_MAX_MIN, 
      :largest_max_regret   => Gecode::Raw::BVAR_REGRET_MAX_MAX
    }
    
    # Maps the names of the supported value branch strategies to the 
    # corresponding constant in Gecode. 
    BRANCH_VALUE_CONSTANTS = {
      :min        => Gecode::Raw::BVAL_MIN,
      :med        => Gecode::Raw::BVAL_MED,
      :max        => Gecode::Raw::BVAL_MAX,
      :split_min  => Gecode::Raw::BVAL_SPLIT_MIN,
      :split_max  => Gecode::Raw::BVAL_SPLIT_MAX
    }
    
    public
  
    # Specifies which variables that should be branched on. One can optionally
    # also select which of the variables that should be used first with the
    # :variable option and which value in that variable's domain that should be 
    # used with the :value option. If nothing is specified then :variable uses
    # :none and value uses :min.
    #
    # The following values can be used with :variable
    # [:none]                 The first unassigned variable.
    # [:smallest_min]         The one with the smallest minimum.
    # [:largest_min]          The one with the largest minimum.
    # [:smallest_max]         The one with the smallest maximum.
    # [:largest_max]          The one with the largest maximum.
    # [:smallest_size]        The one with the smallest size.
    # [:largest_size]         The one with the larges size.
    # [:smallest_degree]      The one with the smallest degree. The degree of a 
    #                         variable is defined as the number of dependant 
    #                         propagators. In case of ties, choose the variable 
    #                         with smallest domain.
    # [:largest_degree]       The one with the largest degree. The degree of a 
    #                         variable is defined as the number of dependant 
    #                         propagators. In case of ties, choose the variable 
    #                         with smallest domain.
    # [:smallest_min_regret]  The one with the smallest min-regret. The 
    #                         min-regret of a variable is the difference between
    #                         the smallest and second-smallest value still in 
    #                         the domain.
    # [:largest_min_regret]   The one with the largest min-regret. The 
    #                         min-regret of a variable is the difference between
    #                         the smallest and second-smallest value still in 
    #                         the domain.
    # [:smallest_max_regret]  The one with the smallest max-regret The 
    #                         max-regret of a variable is the difference between
    #                         the largest and second-largest value still in 
    #                         the domain.
    # [:largest_max_regret]   The one with the largest max-regret. The 
    #                         max-regret of a variable is the difference between
    #                         the largest and second-largest value still in 
    #                         the domain.
    #
    # The following values can be used with :value
    # [:min]        Selects the smallest value.
    # [:med]        Select the median value.
    # [:max]        Selects the largest vale
    # [:split_min]  Selects the lower half of the domain.
    # [:split_max]  Selects the upper half of the domain.
    def branch_on(variables, options = {})
      # Extract optional arguments.
      var_strat = options.delete(:variable) || :none
      val_strat = options.delete(:value) || :min

      # Check that the options are correct.
      unless options.empty?
        raise ArgumentError, 'Unknown branching option given: ' + 
          options.keys.join(', ')
      end
      unless BRANCH_VAR_CONSTANTS.include? var_strat
        raise ArgumentError, "Unknown variable selection strategy: #{var_strat}"
      end
      unless BRANCH_VALUE_CONSTANTS.include? val_strat
        raise ArgumentError, "Unknown value selection strategy: #{val_strat}"
      end

      # Add the branching.
      Gecode::Raw.branch(active_space, variables.to_int_var_array, 
        BRANCH_VAR_CONSTANTS[var_strat], BRANCH_VALUE_CONSTANTS[val_strat])
    end
  end
end