require 'matrix'

module Gecode::Util
  # Methods that make a matrix an enumerable.
  module MatrixEnumMethods
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

  # Extends Matrix so that it's an enumerable.
  class EnumMatrix < Matrix
    include MatrixEnumMethods
    
    def row(i)
      make_vector_enumerable super
    end
    
    def column(i)
      make_vector_enumerable super
    end
    
    def minor(*args)
      matrix = super
      class <<matrix
        include MatrixEnumMethods
      end
      return matrix
    end
    
    private
    
    def make_vector_enumerable(vector)
      class <<vector
        include Enumerable
  
        # Iterates over every element in the matrix.
        def each(&block)
          size.times do |i|
            yield self[i]
          end
        end
      end
      return vector
    end
  end
end