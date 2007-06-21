require File.dirname(__FILE__) + '/spec_helper'

describe 'non-empty bool variable', :shared => true do
  it 'should give a NoMethodError when calling a method that doesn\'t exist' do
    lambda{ @var.this_method_does_not_exists }.should raise_error(NoMethodError)
  end
end

describe Gecode::FreeBoolVar, '(not assigned)' do
  before do
    model = Gecode::Model.new
    @var = model.bool_var
  end
  
  it_should_behave_like 'non-empty bool variable'
  
  it 'should not be assigned' do
    @var.should_not be_assigned
  end
end