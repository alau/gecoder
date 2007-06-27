require File.dirname(__FILE__) + '/spec_helper'

describe Gecode::Model, ' (enum wrapping)' do
  before do
    @model = Gecode::Model.new
    @bool = @model.bool_var
    @int = @model.int_var(1..2)
  end

  it 'should only allow enumerables to be wrapped' do
    lambda do
      @model.instance_eval{ wrap_enum(17) } 
    end.should raise_error(TypeError)
  end

  it 'should allow enumerables of variables to be wrapped' do
    lambda do
      enum = [@bool]
      @model.instance_eval{ wrap_enum(enum) } 
    end.should_not raise_error
  end
  
  it 'should not allow empty enumerables to be wrapped' do
    lambda do 
      @model.instance_eval{ wrap_enum([]) } 
    end.should raise_error(ArgumentError)
  end
  
  it 'should not allow enumerables without variables to be wrapped' do
    lambda do 
      @model.instance_eval{ wrap_enum([17]) } 
    end.should raise_error(TypeError)
  end
  
  it 'should not allow enumerables with only some variables to be wrapped' do
    lambda do 
      enum = [@bool, 17]
      @model.instance_eval{ wrap_enum(enum) } 
    end.should raise_error(TypeError)
  end
  
  it 'should not allow enumerables with mixed types of variables to be wrapped' do
    lambda do 
      enum = [@bool, @int]
      @model.instance_eval{ wrap_enum(enum) } 
    end.should raise_error(TypeError)
  end
end

describe Gecode::IntEnumMethods do
  before do
    @model = Gecode::Model.new
    @int_enum = @model.int_var_array(3, 0..1)
  end
  
  it 'should convert to an int var array' do
    @int_enum.to_int_var_array.should be_kind_of(Gecode::Raw::IntVarArray)
  end
end

describe Gecode::BoolEnumMethods do
  before do
    @model = Gecode::Model.new
    @int_enum = @model.bool_var_array(3)
  end
  
  it 'should convert to a bool var array' do
    @int_enum.to_bool_var_array.should be_kind_of(Gecode::Raw::BoolVarArray)
  end
end