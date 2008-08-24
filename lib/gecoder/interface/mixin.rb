# Provides a mixin alternative to inheriting Gecode::Model. I.e. rather
# than
#
#   class Foo < Gecode::Model
#     def initialize
#       # Define problem.
#     end
#   end
#
# one can use
#
#   class Foo
#     include Gecode::Mixin
#
#     def initialize
#       # Define problem.
#     end
#   end
#
# The preferred method is inheritance. This Mixin is just a hack that
# attempts to imitate the inheritance as good as possible.
module Gecode::Mixin
  def self.included(mod)
    mod.class_eval do
      def gecoder_model
        @gecoder_model ||= Gecode::Model.new
      end

      alias_method :pre_gecoder_method_missing, :method_missing
      def method_missing(method, *args)
        begin
          gecoder_model.send(method, *args)
        rescue NoMethodError
          pre_gecoder_method_missing(method, *args)
        end
      end
      alias_method :mixin_method_missing, :method_missing

      alias_method :pre_gecoder_respond_to?, :respond_to?
      def respond_to?(method)
        pre_gecoder_respond_to?(method) || gecoder_model.respond_to?(method)
      end
      
      def self.method_added(method)
        if method == :method_missing && !@redefining_method_missing
          # The class that is mixing in the mixin redefined method
          # missing. Redefine method missing again to combine the two
          # definitions.
          @redefining_method_missing = true
          class_eval do 
            alias_method :mixee_method_missing, :method_missing
            def combined_method_missing(*args)
              begin
                mixin_method_missing(*args)
              rescue NoMethodError => e
                mixee_method_missing(*args)
              end
            end
            alias_method :method_missing, :combined_method_missing
          end
        end
      end
    end
  end
end
