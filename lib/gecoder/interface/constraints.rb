require 'gecoder/interface/constraints/relation'
require 'gecoder/interface/constraints/distinct'

module Gecode
  # An error signaling that the constraint specified is missing (e.g. one tried
  # to negate a constraint, but no negated form is implemented).
  class MissingConstraintError < StandardError
  end
end