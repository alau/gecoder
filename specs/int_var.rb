require File.dirname(__FILE__) + '/spec_helper'

describe 'non-empty int variable', :shared => true do
  it 'should have min equal to the lower domain bound' do
    @var.min.should equal(@domain.min)
  end
  
  it 'should have max equal to the upper domain bound' do
    @var.max.should equal(@domain.max)
  end
  
  it 'should have size equal to the domain size' do
    @var.size.should equal(@domain.size)
  end
  
  it 'should contain every element in its domain' do 
    @domain.each do |i|
      @var.should be_in(i)
    end
  end
  
  it 'should not contain elements outside its domain' do
    @var.should_not be_in(@domain.min - 1)
    @var.should_not be_in(@domain.max + 1)
  end
  
  it 'should have a width equal to the domain width' do
    @var.width.should equal(@domain.max - @domain.min + 1)
  end
  
  it 'should give a NoMethodError when calling a method that doesn\'t exist' do
    lambda{ @var.this_method_does_not_exists }.should raise_error(NoMethodError)
  end
end

describe Gecode::FreeIntVar, ' (with range domain of size > 1)' do
  before do
    @range = -4..3
    @domain = @range.to_a
    model = Gecode::Model.new
    @var = model.int_var(@range)
  end
  
  it_should_behave_like 'non-empty int variable'
  
  it 'should have a zero degree' do
    @var.degree.should be_zero
  end
  
  it 'should not be assigned' do
    @var.should_not be_assigned
  end
  
  it 'should have a range domain' do
    @var.should be_range
  end
end

describe Gecode::FreeIntVar, ' (defined with three-dot range)' do
  before do
    @range = -4...3
    @domain = @range.to_a
    model = Gecode::Model.new
    @var = model.int_var(@range)
  end
  
  it_should_behave_like 'non-empty int variable'
end

# Many of these fail. It does not appear to be a problem in the Ruby-code, 
# rather IntSet (in Model#int_var) seems to behave strange when e.g. given an 
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
describe Gecode::FreeIntVar, ' (with non-range domain of size > 1)' do
  before do
    @domain = [-3, -2, -1, 1]
    model = Gecode::Model.new
    @var = model.int_var(*@domain)
  end

  it_should_behave_like 'non-empty int variable'
  
  it 'should have a degree equal to the domain degree' do
    @var.degree.should equal(1)
  end
  
  it 'should not be assigned' do
    @var.should_not be_assigned
  end
  
  it 'should not be a range domain' do
    @var.should_not be_range
  end
  
  it 'should not contain the domain\'s holes' do
    @var.should_not be_in(1)
  end
end

describe Gecode::FreeIntVar, '(with a domain of size 1)' do
  before do
    @domain = [1]
    model = Gecode::Model.new
    @var = model.int_var(*@domain)
  end
  
  it_should_behave_like 'non-empty int variable'
  
  it 'should have a zero degree' do
    @var.degree.should be_zero
  end
  
  it 'should be assigned' do
    @var.should be_assigned
  end
  
  it 'should be a range domain' do
    @var.should be_range
  end
end