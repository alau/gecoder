require 'gecoder/interface/constraints/relation'
require 'gecoder/interface/constraints/distinct'
require 'gecoder/interface/constraints/linear'
require 'gecoder/interface/constraints/int_var_constraints'
require 'gecoder/interface/constraints/int_enum_constraints'

module Gecode
  # An error signaling that the constraint specified is missing (e.g. one tried
  # to negate a constraint, but no negated form is implemented).
  class MissingConstraintError < StandardError
  end
end