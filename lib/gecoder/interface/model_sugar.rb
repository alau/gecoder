module Gecode
  # Provides a convenient way to construct a model and then find a
  # solution. The model constructed uses the specified block as 
  # initialization method. The first solution to the model is then
  # returned.
  #
  # For instance
  #
  #   solution = Gecode.solve do
  #     # Do something
  #   end
  # 
  # corresponds to
  # 
  #   class Foo < Gecode::Model
  #     def initialize
  #       # Do something
  #     end
  #   end
  #   solution = Foo.new.solve!
  def self.solve(&block)
    model = Class.new(Gecode::Model)
    model.class_eval do
      def initialize(&init_block)
        instance_eval &init_block
      end
    end
    model.new(&block).solve!
  end
end
