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
    @prices = int_var_array(4, *prices)
    @store = int_var(0...prices.size)
    @price = int_var(*prices)
    branch_on wrap_enum([@store])
  end
end

describe Gecode::Constraints::IntEnum::Element do
  before do
    @model = ElementSampleProblem.new
    @prices = @model.prices
    @price = @model.price
    @store = @model.store
    @fixnum_prices = @model.fixnum_prices
    
    # For constraint option spec.
    @invoke_options = lambda do |hash| 
      @prices[@store].must_be.greater_than(@price, hash) 
      @model.solve!
    end
    @expect_options = lambda do |strength, reif_var|
      if reif_var.nil?
        Gecode::Raw.should_receive(:element).once.with(@model.active_space, 
          an_instance_of(Gecode::Raw::IntVarArray), 
          an_instance_of(Gecode::Raw::IntVar),
          an_instance_of(Gecode::Raw::IntVar), an_instance_of(Fixnum))
        Gecode::Raw.should_receive(:rel).once.with(@model.active_space, 
          an_instance_of(Gecode::Raw::IntVar), Gecode::Raw::IRT_GR,
          an_instance_of(Gecode::Raw::IntVar), strength)
      else
        Gecode::Raw.should_receive(:element).once.with(@model.active_space, 
          an_instance_of(Gecode::Raw::IntVarArray), 
          an_instance_of(Gecode::Raw::IntVar),
          an_instance_of(Gecode::Raw::IntVar), an_instance_of(Fixnum))
        Gecode::Raw.should_receive(:rel).once.with(@model.active_space, 
          an_instance_of(Gecode::Raw::IntVar), Gecode::Raw::IRT_GR,
          an_instance_of(Gecode::Raw::IntVar), 
          an_instance_of(Gecode::Raw::BoolVar), strength)
      end
    end
  end
  
  Gecode::Constraints::Util::RELATION_TYPES.each_pair do |relation, type|
    it "should translate #{relation} with variable right hand side" do
      Gecode::Raw.should_receive(:element).once.with(@model.active_space, 
        an_instance_of(Gecode::Raw::IntVarArray), 
        an_instance_of(Gecode::Raw::IntVar),
        an_instance_of(Gecode::Raw::IntVar), Gecode::Raw::ICL_DEF)
      unless type == Gecode::Raw::IRT_EQ
        Gecode::Raw.should_receive(:rel).once.with(@model.active_space,
          an_instance_of(Gecode::Raw::IntVar), type,
          an_instance_of(Gecode::Raw::IntVar), an_instance_of(Fixnum))
      end
      @prices[@store].must.send(relation, @price)
      @model.solve!
    end
  end

  Gecode::Constraints::Util::NEGATED_RELATION_TYPES.each_pair do |relation, type|
    it "should translate negated #{relation} with variable right hand side" do
      Gecode::Raw.should_receive(:element).once.with(@model.active_space, 
        an_instance_of(Gecode::Raw::IntVarArray), 
        an_instance_of(Gecode::Raw::IntVar),
        an_instance_of(Gecode::Raw::IntVar), Gecode::Raw::ICL_DEF)
      Gecode::Raw.should_receive(:rel).once.with(@model.active_space, 
        an_instance_of(Gecode::Raw::IntVar), type,
        an_instance_of(Gecode::Raw::IntVar), an_instance_of(Fixnum))
      @prices[@store].must_not.send(relation, @price)
      @model.solve!
    end
  end
  
  Gecode::Constraints::Util::RELATION_TYPES.each_pair do |relation, type|
    it "should translate #{relation} with constant right hand side" do
      Gecode::Raw.should_receive(:element).once.with(@model.active_space, 
        an_instance_of(Gecode::Raw::IntVarArray), 
        an_instance_of(Gecode::Raw::IntVar),
        an_instance_of(Gecode::Raw::IntVar), Gecode::Raw::ICL_DEF)
      unless type == Gecode::Raw::IRT_EQ
        Gecode::Raw.should_receive(:rel).once.with(@model.active_space,
          an_instance_of(Gecode::Raw::IntVar), type, 5, an_instance_of(Fixnum))
      end
      @prices[@store].must.send(relation, 5)
      @model.solve!
    end
  end

  Gecode::Constraints::Util::NEGATED_RELATION_TYPES.each_pair do |relation, type|
    it "should translate negated #{relation} with constant right hand side" do
      Gecode::Raw.should_receive(:element).once.with(@model.active_space, 
        an_instance_of(Gecode::Raw::IntVarArray), 
        an_instance_of(Gecode::Raw::IntVar),
        an_instance_of(Gecode::Raw::IntVar), Gecode::Raw::ICL_DEF)
      Gecode::Raw.should_receive(:rel).once.with(@model.active_space,
        an_instance_of(Gecode::Raw::IntVar), type, 5, an_instance_of(Fixnum))
      @prices[@store].must_not.send(relation, 5)
      @model.solve!
    end
  end

  it 'should not disturb normal array access' do
    @fixnum_prices[2].should_not be_nil
    @prices[2].should_not be_nil
  end

  it 'should handle fixnum enums as enumeration' do
    @fixnum_prices[@store].must == @fixnum_prices[2]
    @model.solve!.store.val.should equal(2)
  end

  it 'should raise error on right hand sides of the wrong type' do
    lambda{ @prices[@store].must == 'hello' }.should raise_error(TypeError) 
  end
  
  it_should_behave_like 'constraint with options'
end