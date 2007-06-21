require File.dirname(__FILE__) + '/example_helper'

# Solves the send+more=money problem: 
# http://en.wikipedia.org/wiki/Send%2Bmore%3Dmoney
class SendMoreMoney < Gecode::Model
  def initialize
    # Set up the variables, 8 letters with domain 0..9.
    s,e,n,d,m,o,r,y = @letters = int_var_array(8, 0..9)

    # Set up the constraints.
    (equation_row(s, e, n, d) + equation_row(m, o, r, e)).must == 
      equation_row(m, o, n, e, y) 
      
    s.must_not == 0
    m.must_not == 0
    @letters.must_be.distinct

    # Set the branching.
    branch_on @letters, :variable => :smallest_size, :value => :min
  end

  def to_s
    %w{s e n d m o r y}.zip(@letters).map do |text, letter|
      "#{text}: #{letter.val}" 
    end.join(', ')
  end

  private

  # A helper to make the linear equation a bit tidier. Takes a number of
  # variables and computes the linear combination as if the variable
  # were digits in a base 10 number. E.g. x,y,z becomes
  # 100*x + 10*y + z .
  def equation_row(*variables)
    variables.inject{ |result, variable| variable + result*10 }
  end
end

puts SendMoreMoney.new.solve!.to_s