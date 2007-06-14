require File.dirname(__FILE__) + '/spec_helper'

describe Gecode::Model, ' (integer creation)' do
  before do
    @model = Gecode::Model.new
  end

  it 'should allow the creation of int variables with range' do
    range = 0..3
    @model.int_var(range).should have_domain(range)
  end
  
  # This currently fails, see specs/int_var for an explanation.
  it 'should allow the creation of int variables with elements' do
    domain = [1, 3, 5]
    @model.int_var(*domain).should have_domain(domain)
  end
  
  it 'should allow the creation of int variables with one element' do
    domain = 3
    @model.int_var(domain).should have_domain([domain])
  end
  
  it 'should not accept empty domains' do
    lambda{ @model.int_var }.should raise_error(ArgumentError)
  end
end
