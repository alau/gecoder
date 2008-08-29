require File.dirname(__FILE__) + '/example_helper'

# Solves the cryptarithmetic send+most=money problem while maximizing the value
# of "money".
class SendMoreMoney
  include Gecode::Mixin

  attr :money

  def initialize
    # Set up the variables, 9 letters with domain 0..9.
    s,e,n,d,m,o,s,t,y = @letters = int_var_array(9, 0..9)
    @money = wrap_enum([m,o,n,e,y])
    
    # Set up the constraints.
    # The equation must hold.
    (equation_row(s, e, n, d) + equation_row(m, o, s, t)).must == 
      equation_row(m,o,n,e,y) 
    
    # The initial letters may not be 0.
    s.must_not == 0
    m.must_not == 0
    
    # All letters must be assigned different digits.
    @letters.must_be.distinct

    # Set the branching.
    branch_on @letters, :variable => :smallest_size, :value => :min
  end

  def to_s
    %w{s e n d m o s t y}.zip(@letters).map do |text, letter|
      "#{text}: #{letter.value}" 
    end.join(', ')
  end
  
  private

  # A helper to make the linear equation a bit tidier. Takes a number of
  # variables and computes the linear combination as if the variable
  # were digits in a base 10 number. E.g. x,y,z becomes
  # 100*x + 10*y + z .
  def equation_row(*variables)
    variables.to_number
  end
end

class Array
  # Computes a number of the specified base using the array's elements as 
  # digits.
  def to_number(base = 10)
    inject{ |result, variable| variable + result * base }
  end
end

solution = SendMoreMoney.new.optimize! do |model, best_so_far|
  model.money.to_number.must > best_so_far.money.values.to_number
end
puts solution.to_s
puts "money: #{solution.money.values.to_number}"
