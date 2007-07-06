require File.dirname(__FILE__) + '/../spec_helper'

describe Gecode::Constraints::Expression do
  it 'should raise error if it doesn\'t get all parameters for initialization' do
    lambda do 
      Gecode::Constraints::Expression.new(Gecode::Model.new, :negate => false) 
    end.should raise_error(ArgumentError)
  end
end

describe Gecode::Constraints::IntEnum::Expression do
  it 'should raise error unless lhs is an enum' do
    lambda do
      Gecode::Constraints::IntEnum::Expression.new(Gecode::Model.new, 
        :lhs => 'foo', :negate => false)
    end.should raise_error(TypeError)
  end
end

describe Gecode::Constraints::Int::CompositeStub, ' (not subclassed)' do
  before do
    @con = Gecode::Constraints::Int::CompositeStub.new(Gecode::Model.new, {})
  end

  it 'should raise error when calling #constrain_equal' do
    lambda do 
      @con.instance_eval{ constrain_equal(nil, {}) }
    end.should raise_error(NoMethodError)
  end
end

describe Gecode::Constraints::Constraint, ' (not subclassed)' do
  before do
    @con = Gecode::Constraints::Constraint.new(Gecode::Model.new, {})
  end

  it 'should raise error when calling #post because it\'s not overridden' do
    lambda{ @con.post }.should raise_error(NoMethodError)
  end
end