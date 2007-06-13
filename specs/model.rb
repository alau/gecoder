require File.dirname(__FILE__) + '/spec_helper'

describe Gecode::Model, ' (integer creation)' do
  before do
    @model = Gecode::Model.new
  end

  it 'should allow the creation of int variables with range' do
    range = 0..3
    var = @model.int_var(range)

    var.min.should equal(range.begin)
    var.max.should equal(range.end)
    range_size = range.end - range.begin + 1
    var.size.should equal(range_size)
    var.width.should equal(range_size)
    var.degree.should be_zero
    var.should_not be_assigned
    range.each do |x|
      var.should be_in(x)
    end
    var.should_not be_in(17)
    var.should be_range
  end
  
  # This fails. It does not appear to be a problem in the Ruby-code, rather
  # IntSet (in Model#int_var) seems to behave strange when e.g. given an 
  # array of [1,3,5]. Example:
  # 
  # > set = Gecode::Raw::IntSet.new([1,3,5], 3)
  # > set.size
  # 3    <- This is correct
  # > set.min(0)
  # 4    <- This is not correct, 1 is expected.
  # > set.min(1)
  # -1037935314    <- This is not correct, 3 is expected.
  # 
  # It works fine through Gecode/J, so it's probably not something in Gecode
  # that's causing the strange behavior. Possibly it's something in the 
  # conversion of the arrays, but I can't find any other method that uses
  # constant arrays to test with.
  it 'should allow the creation of int variables with elements' do
    domain = [1, 3, 5]
    var = @model.int_var(*domain)

    var.min.should equal(domain.min)
    var.max.should equal(domain.max)
    var.size.should equal(domain.size)
    var.width.should equal(domain.size)
    var.degree.should be_zero
    var.should_not be_assigned
    range.each do |x|
      var.should be_in(x)
    end
    var.should_not be_in(17)
    var.should_not be_range
  end
  
  it 'should allow the creation of int variables with one element' do
    domain = 3
    var = @model.int_var(domain)
    
    var.size.should equal(1)
    var.should be_assigned
    var.val.should equal(domain)
  end
  
  it 'should not accept empty domains' do
    lambda{ @model.int_var }.should raise_error(ArgumentError)
  end
end