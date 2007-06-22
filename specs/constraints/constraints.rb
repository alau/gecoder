require File.dirname(__FILE__) + '/../spec_helper'

describe Gecode::Constraints::Expression do
  it 'should raise error if it doesn\'t get all parameters for initialization' do
    lambda do 
      Gecode::Constraints::Expression.new(:space => nil, :negate => false) 
    end.should raise_error(ArgumentError)
  end
end

describe Gecode::Constraints::IntEnum::Expression do
  it 'should raise error unless lhs is an enum' do
    lambda do
      Gecode::Constraints::IntEnum::Expression.new(:space => nil, 
        :lhs => 'foo', :negate => false)
    end.should raise_error(TypeError)
  end
end