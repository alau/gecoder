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
  
  it "should say that it's not assigned when inspecting" do
    @var.inspect.should include('unassigned')
  end
end

describe Gecode::FreeBoolVar, '(assigned true)' do
  before do
    model = Gecode::Model.new
    @var = model.bool_var
    @var.must_be.true
    model.solve!
  end
  
  it_should_behave_like 'non-empty bool variable'
  
  it 'should be assigned' do
    @var.should be_assigned
  end
  
  it 'should respond true to true?' do
    @var.true?.should be_true
  end
  
  it 'should not respond true to false?' do
    @var.false?.should_not be_true
  end
  
  it "should say that it's true when inspecting" do
    @var.inspect.should include('true')
  end
end

describe Gecode::FreeBoolVar, '(assigned false)' do
  before do
    model = Gecode::Model.new
    @var = model.bool_var
    @var.must_be.false
    model.solve!
  end
  
  it_should_behave_like 'non-empty bool variable'
  
  it 'should be assigned' do
    @var.should be_assigned
  end
  
  it 'should respond not true to true?' do
    @var.true?.should_not be_true
  end
  
  it 'should respond true to false?' do
    @var.false?.should be_true
  end
  
  it "should say that it's false when inspecting" do
    @var.inspect.should include('false')
  end
end