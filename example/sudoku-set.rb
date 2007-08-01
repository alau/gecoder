require File.dirname(__FILE__) + '/example_helper'
require 'enumerator'

# Solves the sudoku problem using sets. The model used is a fairly direct 
# translation of the corresponding Gecode example: 
# http://www.gecode.org/gecode-doc-latest/sudoku-set_8cc-source.html .
class SudokuSet < Gecode::Model
  # Takes a 9x9 matrix of values in the initial sudoku, 0 if the square is 
  # empty. 
  def initialize(predefined_values)
    unless predefined_values.column_size == 9 and predefined_values.row_size == 9
      raise ArgumentError, 'The matrix with predefined values must have ' +
        'dimensions 9x9.'
    end
    
    @size = n = predefined_values.row_size
    sub_matrix_size = Math.sqrt(n).round
    
    # Create one set per assignable number (i.e. 1..9). Each set contains the 
    # position of all squares that the number is located in. The squares are 
    # given numbers from 1 to 81. Each set therefore has an empty lower bound 
    # (since we have no guarantees where a number will end up) and 1..81 as 
    # upper bound (as it may potentially occurr in any square). We know that
    # each assignable number must occurr 9 times in a solved sudoku, so we 
    # set the cardinality to 9..9 .
    @sets = set_var_array(n, [], 1..n*n, n..n)
    predefined_values.row_size.times do |i|
      predefined_values.column_size.times do |j|
        unless predefined_values[i,j].zero?
          # We add the constraint that the square position must occurr in the 
          # set corresponding to the predefined value.
          @sets[predefined_values[i,j] - 1].must_be.superset_of [i*n + j+1]
        end
      end
    end

    # Build arrays containing the square positions of each row and column.
    rows = []
    columns = []
    n.times do |i|
      rows << ((i*n + 1)..(i*n + 9))
      columns << [1, 10, 19, 28, 37, 46, 55, 64, 73].map{ |e| e + i }
    end
    
    # Build arrays containing the square positions of each block.
    blocks = []
    sub_matrix_size.times do |i|
      sub_matrix_size.times do |j|
        blocks << [1, 2, 3, 10, 11, 12, 19, 20, 21].map{ |e| e + (j*27)+(i*3) }
      end
    end
    
    # All sets must be pairwise disjoint since two numbers can't be assigned to
    # the same square.
    n.times do |i|
      (i + 1).upto(n - 1) do |j|
        @sets[i].must_be.disjoint_with @sets[j]
      end
    end
    # The above implies that the sets must be distinct (since cardinality 0 is
    # not allowed), but we also explicitly add the distinctness constraint.
    @sets.must_be.distinct(:size => n)

    # The sets must intersect in exactly one element with each row column and
    # block. I.e. an assignable number must be assigned exactly once in each
    # row, column and block. We specify the constraint by expressing that the 
    # intersection must be equal with a set variable with cardinality 1.
    @sets.each do |set|
      rows.each do |row|
        set.intersection(row).must == set_var([], 1..n*n, 1..1)
      end
      columns.each do |column|
        set.intersection(column).must == set_var([], 1..n*n, 1..1)
      end
      blocks.each do |block|
        set.intersection(block).must == set_var([], 1..n*n, 1..1)
      end
    end

    # Branching.
    branch_on @sets, :variable => :none, :value => :min
  end
  
  # Outputs the assigned numbers in a grid.
  def to_s
    squares = []
    @sets.values.each_with_index do |positions, i|
      positions.each{ |square_position| squares[square_position - 1] = i + 1 }
    end
    rows = []
    squares.each_slice(@size){ |slice| rows << slice.join(' ') }
    rows.join("\n")
  end
end

predefined_squares = Matrix[
  [0,0,0, 2,0,5, 0,0,0],
  [0,9,0, 0,0,0, 7,3,0],
  [0,0,2, 0,0,9, 0,6,0],
    
  [2,0,0, 0,0,0, 4,0,9],
  [0,0,0, 0,7,0, 0,0,0],
  [6,0,9, 0,0,0, 0,0,1],
      
  [0,8,0, 4,0,0, 1,0,0],
  [0,6,3, 0,0,0, 0,8,0],
  [0,0,0, 6,0,8, 0,0,0]]
puts(SudokuSet.new(predefined_squares).solve! || 'Failed').to_s