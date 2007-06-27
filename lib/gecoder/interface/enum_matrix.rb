require 'matrix'

module Gecode::Util
  # Extends Matrix so that it's an enumerable.
  class EnumMatrix < Matrix
    include Enumerable
  
    # Iterates over every element in the matrix.
    def each(&block)
      row_size.times do |i|
        column_size.times do |j|
          yield self[i,j]
        end
      end
    end
  end
end