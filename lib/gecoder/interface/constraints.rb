module Gecode
  # An error signaling that the constraint specified is missing (e.g. one tried
  # to negate a constraint, but no negated form is implemented).
  class MissingConstraintError < StandardError
  end
  
  # A module containing all the constraints.
  module Constraints
  end
end

require 'gecoder/interface/constraints/int_var_constraints'
require 'gecoder/interface/constraints/int_enum_constraints'
