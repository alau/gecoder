require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/constraint_helper'

describe Gecode::Constraints::IntEnum::Equality do
  before do
    @model = Gecode::Model.new
    @vars = @model.int_var_array(4, -2..2)
    @invoke_options = lambda do |hash| 
      @vars.must_be.equal(hash)
      @model.solve!
    end
    @expect_options = lambda do |strength, reif_var|
      Gecode::Raw.should_receive(:eq).once.with(
        an_instance_of(Gecode::Raw::Space), 
        anything, strength)
    end
  end
  
  it 'should translate equality constraints' do
    @expect_options.call(Gecode::Raw::ICL_DEF, nil)
    @invoke_options.call({})
    @vars.must_be.equal
  end

  it 'should not allow negation' do
    lambda{ @vars.must_not_be.equal }.should raise_error(
      Gecode::MissingConstraintError)
  end
  
  it_should_behave_like 'constraint with strength option'
end