require File.dirname(__FILE__) + '/spec_helper'

describe Gecode::Model, ' (enum wrapping)' do
  before do
    @model = Gecode::Model.new
  end

  it 'should only allow enumerables to be wrapped' do
    lambda{ @model.instance_eval{ wrap_enum(17)} }.should raise_error(TypeError)
  end
end