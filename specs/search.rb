require File.dirname(__FILE__) + '/spec_helper'
require 'set'

class SampleProblem < Gecode::Model
  attr :var
  attr :array
  attr :hash
  attr :nested_enum
  
  def initialize(domain)
    vars = self.int_var_array(1,domain)
    @var = vars.first
    @var.must > 1
    @array = [@var]
    @hash = {:a => var}
    @nested_enum = [1,2,[@var],[7, {:b => var}]]
    
    branch_on vars, :variable => :smallest_size, :value => :min
  end
end

class SampleOptimizationProblem < Gecode::Model
  attr :x
  attr :y
  attr :z
  
  def initialize
    @x,@y = int_var_array(2, 0..5)
    @z = int_var(0..25)
    (@x * @y).must == @z 
    
    branch_on wrap_enum([@x, @y]), :variable => :smallest_size, :value => :min
  end
end

class SampleOptimizationProblem2 < Gecode::Model
  attr :money
  
  def initialize
    @money = int_var_array(3, 0..9)
    @money.must_be.distinct
    @money.to_number.must < 500 # Otherwise it takes some time.
    
    branch_on @money, :variable => :smallest_size, :value => :min
  end
end

class Array
  # Computes a number of the specified base using the array's elements as 
  # digits.
  def to_number(base = 10)
    inject{ |result, variable| variable + result * base }
  end
end

describe Gecode::Model, ' (with multiple solutions)' do
  before do
    @domain = 0..3
    @solved_domain = [2]
    @model = SampleProblem.new(@domain)
  end

  it 'should pass a solution to the block given in #solution' do
    @model.solution do |s|
      s.var.should have_domain(@solved_domain)
    end
  end
  
  it 'should only evaluate the block for one solution in #solution' do
    i = 0
    @model.solution{ |s| i += 1 }
    i.should equal(1)
  end
  
  it 'should return the result of the block when calling #solution' do
    @model.solution{ |s| 'test' }.should == 'test'
  end
  
  it 'should pass every solution to #each_solution' do
    solutions = []
    @model.each_solution do |s|
      solutions << s.var.value
    end
    Set.new(solutions).should == Set.new([2,3])
  end
end

describe Gecode::Model, ' (after #solve!)' do
  before do
    @domain = 0..3
    @solved_domain = [2]
    @model = SampleProblem.new(@domain)
    @model.solve!
  end

  it 'should have updated the variables domains' do
    @model.var.should have_domain(@solved_domain)
  end

  it 'should have updated variables in arrays' do
    @model.array.first.should have_domain(@solved_domain)
  end
  
  it 'should have updated variables in hashes' do
    @model.hash.values.first.should have_domain(@solved_domain)
  end
  
  it 'should have updated variables in nested enums' do
    enum = @model.solve!.nested_enum
    enum[2].first.should have_domain(@solved_domain)
    enum[3][1][:b].should have_domain(@solved_domain)
    
    enum = @model.nested_enum
    enum[2].first.should have_domain(@solved_domain)
    enum[3][1][:b].should have_domain(@solved_domain)
  end
end

describe 'reset model', :shared => true do
  it 'should have reset variables' do
    @model.var.should have_domain(@reset_domain)
  end
  
  it 'should have reset variables in nested enums' do
    enum = @model.nested_enum
    enum[2].first.should have_domain(@reset_domain)
    enum[3][1][:b].should have_domain(@reset_domain)
  end
end

describe Gecode::Model, ' (after #reset!)' do
  before do
    @domain = 0..3
    @reset_domain = 2..3
    @model = SampleProblem.new(@domain)
    @model.solve!
    @model.reset!
  end
  
  it_should_behave_like 'reset model'
end

describe Gecode::Model, ' (after #solution)' do
  before do
    @domain = 0..3
    @reset_domain = 2..3
    @model = SampleProblem.new(@domain)
    @model.solution{ |s| }
  end
  
  it_should_behave_like 'reset model'
end

describe Gecode::Model, ' (after #each_solution)' do
  before do
    @domain = 0..3
    @reset_domain = 2..3
    @model = SampleProblem.new(@domain)
    @model.each_solution{ |s| }
  end
  
  it_should_behave_like 'reset model'
end

describe Gecode::Model, ' (without solution)' do
  before do
    @domain = 0..3
    @model = SampleProblem.new(@domain)
    @model.var.must < 0
  end
  
  it 'should return nil when calling #solution' do
    @model.var.must < 0
    @model.solution{ |s| 'test' }.should be_nil
  end
  
  it 'should return nil when calling #solve!' do
    @model.solve!.should be_nil
  end
  
  it 'should return nil when calling #optimize!' do
    @model.optimize!{}.should be_nil
  end
end

describe Gecode::Model, ' (without constraints)' do
  before do
    @model = Gecode::Model.new
    @x = @model.int_var(0..1)
  end
  
  it 'should produce a solution' do
    @model.solve!.should_not be_nil
  end
end

describe Gecode::Model, '(optimization search)' do
  it 'should optimize the solution' do
    solution = SampleOptimizationProblem.new.optimize! do |model, best_so_far|
      model.z.must > best_so_far.z.value
    end
    solution.should_not be_nil
    solution.x.value.should == 5
    solution.y.value.should == 5
    solution.z.value.should == 25
  end
  
  it 'should not be bothered by garbage collecting' do
    # This goes through 400+ spaces.
    solution = SampleOptimizationProblem2.new.optimize! do |model, best_so_far|
      model.money.to_number.must > best_so_far.money.values.to_number
    end
    solution.should_not be_nil
    solution.money.values.to_number.should == 498
  end
  
  it 'should raise error if no constrain proc has been defined' do
    lambda do 
      Gecode::Model.constrain(nil, nil) 
    end.should raise_error(NotImplementedError)
  end
  
  it 'should not have problems with variables being created in the optimization block' do
    solution = SampleOptimizationProblem.new.optimize! do |model, best_so_far|
      tmp = model.int_var(0..25)
      tmp.must == model.z
      tmp.must > best_so_far.z.value
    end
    solution.should_not be_nil
    solution.x.value.should == 5
    solution.y.value.should == 5
    solution.z.value.should == 25
  end

  it 'should not have problems with variables being created in the optimization block (2)' do
    solution = SampleOptimizationProblem.new.optimize! do |model, best_so_far|
      tmp = model.int_var(0..25)
      tmp.must == model.z
      (tmp + tmp).must > best_so_far.z.value*2
    end
    solution.should_not be_nil
    solution.x.value.should == 5
    solution.y.value.should == 5
    solution.z.value.should == 25
  end
end