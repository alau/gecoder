require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/constraint_helper'

describe Gecode::Constraints::Int::Domain do
  before do
    @model = Gecode::Model.new
    @domain = 0..3
    @x = @model.int_var(@domain)
    @range_domain = 1..2
    @three_dot_range_domain = 1...2
    @non_range_domain = [1, 3]
    
    @invoke_options = lambda do |hash| 
      @x.must_be.in(@non_range_domain, hash) 
      @model.solve!
    end
    @expect_options = lambda do |strength, reif_var|
      if reif_var.nil?
        Gecode::Raw.should_receive(:dom).once.with(@model.active_space, 
          @x.bind, an_instance_of(Gecode::Raw::IntSet), strength)
      else
        Gecode::Raw.should_receive(:dom).once.with(@model.active_space, 
          @x.bind, an_instance_of(Gecode::Raw::IntSet), 
          an_instance_of(Gecode::Raw::BoolVar), strength)
      end
    end
  end
  
  it 'should translate domain constraints with range domains' do
    Gecode::Raw.should_receive(:dom).once.with(@model.active_space, 
      @x.bind, @range_domain.first, @range_domain.last, Gecode::Raw::ICL_DEF)
    @x.must_be.in @range_domain
    @model.solve!
  end

  it 'should translate domain constraints with three dot range domains' do
    Gecode::Raw.should_receive(:dom).once.with(@model.active_space, 
      @x.bind, @three_dot_range_domain.first, @three_dot_range_domain.last, 
      Gecode::Raw::ICL_DEF)
    @x.must_be.in @three_dot_range_domain
    @model.solve!
  end
  
  it 'should translate domain constraints with non-range domains' do
    @expect_options.call(Gecode::Raw::ICL_DEF, nil)
    @invoke_options.call({})
  end
  
  it 'should handle negation' do
    @x.must_not_be.in @range_domain
    @model.solve!
    @x.should have_domain(@domain.to_a - @range_domain.to_a)
  end
  
  it_should_behave_like 'constraint with options'
end