require File.dirname(__FILE__) + '/example_helper'

# Solves the sudoku problem: http://en.wikipedia.org/wiki/Soduko
class Sudoku < Gecode::Model
  # Takes a matrix of values in the initial sudoku, 0 if the square is empty. 
  # The matrix must be square with a square size. 
  def initialize(values)
    # Verify that the input is of a valid size.
    @size = n = values.row_size
    sub_matrix_size = Math.sqrt(n).round
    unless values.square? and sub_matrix_size**2 == n
      raise ArgumentError, 'Incorrect value matrix size.'
    end
    sub_count = sub_matrix_size
    
    # Create the squares and initialize them.
    @squares = int_var_matrix(n, n, 1..n)
    values.row_size.times do |i|
      values.column_size.times do |j|
        @squares[i,j].must == values[i,j] unless values[i,j] == 0
      end
    end
    
    # Constraints.
    n.times do |i|
      # All rows must contain distinct numbers.
      wrap_enum(@squares.row(i)).must_be.distinct(:strength => :domain)
      # All columns must contain distinct numbers.
      wrap_enum(@squares.column(i)).must_be.distinct(:strength => :domain)
      # All sub-matrices must contain distinct numbers.
      wrap_enum(@squares.minor(
        (i % sub_count) * sub_matrix_size, 
        sub_matrix_size, 
        (i / sub_count) * sub_matrix_size, 
        sub_matrix_size)).must_be.distinct(:strength => :domain)
    end
    
    # Branching, we use first-fail heuristic.
    branch_on @squares, :variable => :smallest_size, :value => :min
  end
  
  # Display the solved sudoku in a grid.  
  def to_s
    separator = '+' << '-' * (3 * @size + (@size - 1)) << "+\n"
    res = (0...@size).inject(separator) do |s, i|
      (0...@size).inject(s + '|') do |s, j|
        s << " #{@squares[i,j].val} |"
      end << "\n" << separator
    end
  end
end

given_squares = Matrix[
  [0,0,0, 2,0,5, 0,0,0],
  [0,9,0, 0,0,0, 7,3,0],
  [0,0,2, 0,0,9, 0,6,0],
    
  [2,0,0, 0,0,0, 4,0,9],
  [0,0,0, 0,7,0, 0,0,0],
  [6,0,9, 0,0,0, 0,0,1],
      
  [0,8,0, 4,0,0, 1,0,0],
  [0,6,3, 0,0,0, 0,8,0],
  [0,0,0, 6,0,8, 0,0,0]]
puts Sudoku.new(given_squares).solve!.to_s
