require File.dirname(__FILE__) + '/example_helper'

class EquationProblem < Gecode::Model
  def initialize
    x, y, z = vars_is_an int_var_array(3, 0..9)

    (x + y).must == z
    x.must == y - 3

    branch_on vars
  end
end

puts 'x y z'
puts EquationProblem.new.solve!.vars.values.join(' ')
