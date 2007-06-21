require File.dirname(__FILE__) + '/../spec_helper'

class LinearSampleProblem < Gecode::Model
  attr :x
  attr :y
  attr :z
  
  def initialize(x_dom, y_dom, z_dom)
    @x = self.int_var(x_dom)
    @y = self.int_var(y_dom)
    @z = self.int_var(z_dom)
    branch_on wrap_enum([@x, @y, @z])
  end
end

describe Gecode::Constraints::Int::Linear do
  before do
    @x_dom = 0..2
    @y_dom = -3..3
    @z_dom = 0..10
    @model = LinearSampleProblem.new(@x_dom, @y_dom, @z_dom)
    @x = @model.x
    @y = @model.y
    @z = @model.z
  end

  it 'should handle addition with a variable' do
    (@x + @y).must == 0
    sol = @model.solve!
    x = sol.x.val
    y = sol.y.val
    (x + y).should be_zero
  end
  
  it 'should handle addition with multiple variables' do
    (@x + @y + @z).must == 0
    sol = @model.solve!
    x = sol.x.val
    y = sol.y.val
    z = sol.z.val
    (x + y + z).should be_zero
  end
  
  it 'should handle subtraction with a variable' do
    (@x - @y).must == 0
    sol = @model.solve!
    x = sol.x.val
    y = sol.y.val
    (x - y).should be_zero
  end
  
  it 'should handle non-zero constants as right hand side' do
    (@x + @y).must == 1
    sol = @model.solve!
    x = sol.x.val
    y = sol.y.val
    (x + y).should equal(1)
  end
  
  it 'should handle variables as right hand side' do
    (@x + @y).must == @z
    sol = @model.solve!
    x = sol.x.val
    y = sol.y.val
    z = sol.z.val
    (x + y).should equal(z)
  end
  
  it 'should handle linear expressions as right hand side' do
    (@x + @y).must == @z + @y
    sol = @model.solve!
    x = sol.x.val
    y = sol.y.val
    z = sol.z.val
    (x + y).should equal(z + y)
  end
  
  it 'should raise error on invalid right hand sides' do
    lambda{ ((@x + @y).must == 'z') }.should raise_error(TypeError) 
  end
  
  it 'should handle coefficients other than 1' do
    (@x * 2 + @y).must == 0
    sol = @model.solve!
    x = sol.x.val
    y = sol.y.val
    (2*x + y).should equal(0)
  end
  
  it 'should handle addition with constants' do
    (@y + 2).must == 1
    sol = @model.solve!
    y = sol.y.val
    (y + 2).should equal(1)
  end
  
  it 'should handle subtraction with a constant' do
    (@x - 2).must == 0
    sol = @model.solve!
    x = sol.x.val
    (x - 2).should be_zero
  end
  
  it 'should a single variable as left hande side' do
    @x.must == @y + @z
    sol = @model.solve!
    x = sol.x.val
    y = sol.y.val
    z = sol.z.val
    x.should equal(y + z)
  end
  
  it 'should handle parenthesis' do
    (@x - (@y + @z)).must == 1
    sol = @model.solve!
    x = sol.x.val
    y = sol.y.val
    z = sol.z.val
    (x - (y + z)).should equal(1)
  end
  
  it 'should handle multiplication of parenthesis' do
    (((@x + @y*10)*10 + @z)*10).must == 0
    sol = @model.solve!
    x = sol.x.val
    y = sol.y.val
    z = sol.z.val
    (((x + y*10)*10 + z)*10).should equal(0)
  end
  
  relations = ['>', '>=', '<', '<=', '==']
  
  relations.each do |relation|
    it "should handle #{relation} with constant integers" do
      (@x + @y).must.send(relation, 1)
      sol = @model.solve!
      sol.should_not be_nil
      (sol.x.val + sol.y.val).should.send(relation, 1)
    end
  end
  
  relations.each do |relation|
    it "should handle negated #{relation} with constant integers" do
      (@x + @y).must_not.send(relation, 1)
      sol = @model.solve!
      sol.should_not be_nil
      (sol.x.val + sol.y.val).should_not.send(relation, 1)
    end
  end
  
  it 'should translate reification' do
    # TODO: what do we mock?
    (@x + @y).must_be.less_than(2, :reify => @model.bool_var)
  end
  
  # This does not spec all relations, but should be fine.
  { :default  => Gecode::Raw::ICL_DEF,
    :value    => Gecode::Raw::ICL_VAL,
    :bounds   => Gecode::Raw::ICL_BND,
    :domain   => Gecode::Raw::ICL_DOM
  }.each_pair do |name, gecode_value|
    it "should translate propagation strength #{name}" do
      # TODO: what do we mock
      (@x + @y).must.equal(0, :strength => name)
    end
  end
  
  it 'should default to using default as propagation strength' do
    # TODO: what do we mock
    @x.must_be.greater_than(@y + @z)
  end
  
  it 'should raise errors for unrecognized options' do
    lambda{ (@x + @y).must_be.equal_to(0, :does_not_exist => :foo) }.should(
      raise_error(ArgumentError))
  end
  
  it 'should raise errors for unrecognized propagation strengths' do
    lambda{ (@x + @y).must_be.equal_to(0, :strength => :does_not_exist) }.should(
      raise_error(ArgumentError))
  end
  
  it 'should raise errors for reification variables of incorrect type' do
    lambda{ (@x + @y).must_be.equal_to(0, :reify => :foo) }.should(
      raise_error(TypeError))
  end
end