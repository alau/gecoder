require File.dirname(__FILE__) + '/spec_helper'

class MixinSampleProblem
  include Gecode::Mixin

  def initialize
    x, y, z = vars_is_an int_var_array(3, 0..9)

    (x + y).must == z
    x.must == y - 3
    vars.must_be.distinct

    branch_on vars
  end
end

class ClassWithMethodMissing
  include Gecode::Mixin

  def method_missing(*args)
    return :foo
  end
end

describe Gecode::Mixin, ' (mixed into a class)' do
  before do
    @mix = Object.new
    class <<@mix
      include Gecode::Mixin
    end

    @model = Gecode::Model.new
  end

  it 'should respond to everything that Gecode::Model does' do
    @model.public_methods.sort.each do |method|
      @mix.respond_to?(method).should be_true
    end
  end

  it 'should solve a sample problem' do
    lambda do
      MixinSampleProblem.new.solve!.vars.values
    end.should_not raise_error
  end

  it 'should not mess with classes defining methad missing' do
    model = ClassWithMethodMissing.new

    # Should not completely overwrite #method_missing.
    model.does_not_exist.should == :foo

    # Should still allow *_is_a sugar .
    bool_var = model.bool_var
    model.foo_is_a(bool_var).should == bool_var
  end
end
