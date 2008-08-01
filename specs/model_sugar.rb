require File.dirname(__FILE__) + '/spec_helper'

describe Gecode, ' (Model sugar)' do
  it 'should provide #solve as sugar for constructing a model and running solve!' do
    Gecode.solve do
      numbers_is_an int_var_array(2, 0..5)
      x, y = numbers
      (x * y).must == 25
      branch_on numbers
    end.numbers.values.should == [5,5]
  end
end
