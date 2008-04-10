require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/constraint_helper'

class ElementSampleProblem < Gecode::Model
  attr :prices
  attr :store
  attr :price
  attr :fixnum_prices
  
  def initialize
    prices = [17, 63, 45, 63]
    @fixnum_prices = wrap_enum(prices)
    @prices = int_var_array(4, prices)
    @store = int_var(0...prices.size)
    @price = int_var(prices)
    branch_on wrap_enum([@store])
  end
end

describe Gecode::Constraints::IntEnum::Element do
  before do
    @model = ElementSampleProblem.new
    @prices = @model.prices
    @target = @price = @model.price
    @store = @model.store
    @fixnum_prices = @model.fixnum_prices
    
    # Creates an expectation corresponding to the specified input.
    @expect = lambda do |element, relation, target, strength, kind, reif_var, negated|
      @model.allow_space_access do
        target = an_instance_of(Gecode::Raw::IntVar) if target.respond_to? :bind
        element = an_instance_of(Gecode::Raw::IntVar) if element.respond_to? :bind
        if reif_var.nil?
          if !negated and relation == Gecode::Raw::IRT_EQ and 
              !target.kind_of? Fixnum
            Gecode::Raw.should_receive(:element).once.with( 
              an_instance_of(Gecode::Raw::Space), 
              an_instance_of(Gecode::Raw::IntVarArray), 
              element, target, strength, kind)
          else
            Gecode::Raw.should_receive(:element).once.with(
              an_instance_of(Gecode::Raw::Space), 
              an_instance_of(Gecode::Raw::IntVarArray), 
              element, an_instance_of(Gecode::Raw::IntVar), strength, kind)
            Gecode::Raw.should_receive(:rel).once.with(
              an_instance_of(Gecode::Raw::Space), 
              an_instance_of(Gecode::Raw::IntVar), 
              relation, target, strength, kind)
          end
        else
          Gecode::Raw.should_receive(:element).once.with(
            an_instance_of(Gecode::Raw::Space), 
            an_instance_of(Gecode::Raw::IntVarArray), 
            element, an_instance_of(Gecode::Raw::IntVar), strength, kind)
          Gecode::Raw.should_receive(:rel).once.with(
            an_instance_of(Gecode::Raw::Space), 
            an_instance_of(Gecode::Raw::IntVar), relation, target, 
            an_instance_of(Gecode::Raw::BoolVar), strength, kind)
        end
      end
    end

    # For constraint option spec.
    @invoke_options = lambda do |hash| 
      @prices[@store].must_be.greater_than(@price, hash) 
      @model.solve!
    end
    @expect_options = option_expectation do |strength, kind, reif_var|
      @expect.call(@store, Gecode::Raw::IRT_GR, @price, strength, kind, 
        reif_var, false)
    end
    
    # For composite spec.
    @invoke_relation = lambda do |relation, target, negated|
      if negated
        @prices[@store].must_not.send(relation, target)
      else
        @prices[@store].must.send(relation, target)
      end
      @model.solve!
    end
    @expect_relation = lambda do |relation, target, negated|
      @expect.call(@store, relation, target, Gecode::Raw::ICL_DEF, 
        Gecode::Raw::PK_DEF, nil, negated)
    end
  end

  it 'should not disturb normal array access' do
    @fixnum_prices[2].should_not be_nil
    @prices[2].should_not be_nil
  end

  it 'should handle fixnum enums as enumeration' do
    @fixnum_prices[@store].must == @fixnum_prices[2]
    @model.solve!.store.value.should equal(2)
  end
  
  it 'should translate reification when using equality' do
    bool_var = @model.bool_var
    @expect.call(@store, Gecode::Raw::IRT_EQ, @target, Gecode::Raw::ICL_DEF, 
      Gecode::Raw::PK_DEF, bool_var, false)
    @prices[@store].must_be.equal_to(@target, :reify => bool_var)
    @model.solve!
  end
  
  it_should_behave_like 'composite constraint'
  it_should_behave_like 'reifiable constraint'
end