require File.dirname(__FILE__) + '/example_helper'

# An example of using the raw bindings. Solves the send+more=money problem.

# Variables
space = Gecode::Raw::Space.new
letters = Gecode::Raw::IntVarArray.new(space, 8, 0, 9)
space.own(letters, 'letters')
s, e, n, d, m, o, r, y = (0..7).to_a.map{ |i| letters.at(i) }

# Constraints
Gecode::Raw::post(space, (s * 1000 + e * 100 + n * 10  + d   + 
                     m * 1000 + o * 100 + r * 10  + e).
            equal(m * 10000 + o * 1000 + n * 100 + e * 10  + y ), 
            Gecode::Raw::ICL_DEF, Gecode::Raw::PK_DEF)
Gecode::Raw::rel(space, s, Gecode::Raw::IRT_NQ, 0, Gecode::Raw::ICL_DEF, 
  Gecode::Raw::PK_DEF)
Gecode::Raw::rel(space, m, Gecode::Raw::IRT_NQ, 0, Gecode::Raw::ICL_DEF, 
  Gecode::Raw::PK_DEF)
Gecode::Raw::distinct(space, letters, Gecode::Raw::ICL_DEF, Gecode::Raw::PK_DEF)

# Branching.
Gecode::Raw::branch(space, letters, 
  Gecode::Raw::INT_VAR_SIZE_MIN, Gecode::Raw::INT_VAL_MIN)

# Search
COPY_DIST = 16
ADAPTATION_DIST = 4 
dfs = Gecode::Raw::DFS.new(space, COPY_DIST, ADAPTATION_DIST, 
  Gecode::Raw::Search::Stop.new)

space = dfs.next
if space.nil?
  puts 'Failed'
else
  puts 'Solution:'
  correct_letters = space.intVarArray('letters')
  arr = []
  correct_letters.size.times do |i|
    arr << correct_letters.at(i).val
  end
  puts arr.join(' ')
end

