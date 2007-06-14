require File.dirname(__FILE__) + '/spec_helper'

describe 'Space', :shared => true do
  it 'should give different indices when creating int variables' do
    @space.new_int_vars(0, 17).should_not equal(@space.new_int_vars(0, 17))
  end
  
  it 'should give different indices when creating multiple int variables' do
    @space.new_int_vars(0, 17, 17).uniq.size.should equal(17)
  end
  
  it 'should not return nil for created int variables' do
    @space.new_int_vars(0, 17, 4).each do |i|
      @space.int_var(i).should_not be_nil
    end
  end
  
  it 'should return nil when requesting int variables with negative indices' do
    @space.int_var(-1).should be_nil
  end
end

describe Gecode::Raw::Space, ' (new)' do
  before do
    @space = Gecode::Raw::Space.new
  end
  
  it 'should return nil when requesting int variables' do
    @space.int_var(0).should be_nil
  end
  
  it_should_behave_like 'Space'
end

describe Gecode::Raw::Space, ' (with items)' do
  before do
    @space = Gecode::Raw::Space.new
    @first = @space.new_int_vars(1, 4).first
    @second = @space.new_int_vars(-5, 5).first
  end
  
  it_should_behave_like 'Space'
  
  it 'should give int variables with the correct domains' do
    @space.int_var(@first).min.should equal(1)
    @space.int_var(@first).max.should equal(4)
    @space.int_var(@second).min.should equal(-5)
    @space.int_var(@second).max.should equal(5)
  end
end