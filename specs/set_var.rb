require File.dirname(__FILE__) + '/spec_helper'

describe Gecode::FreeSetVar, '(not assigned)' do
  before do
    model = Gecode::Model.new
    @var = model.set_var(0..3, 3..4)
  end
  
  it 'should not be assigned' do
    @var.should_not be_assigned
  end
  
  it 'should give glb and lub ranges when inspecting' do
    @var.inspect.should include('lub-range')
    @var.inspect.should include('glb-range')
  end
end

describe Gecode::FreeSetVar, '(assigned)' do
  before do
    model = Gecode::Model.new
    @var = model.set_var(1..1, 1..1)
    model.solve!
  end
  
  it 'should be assigned' do
    @var.should be_assigned
  end
  
  it "should give it's value when inspecting" do
    @var.inspect.should include('1..1')
    @var.inspect.should_not include('lub-range')
  end
end
