module Fixjour
  # This generates a new instance of a model object for 
  # the new_[model] method.
  class Generator
    attr_reader :klass, :block
  
    def initialize(klass, block)
      @klass, @block = klass, block
    end
  
    def call(context, overrides={})
      overrides = OverridesHash.new(overrides)
      result = block.bind(context).call(*args(overrides))
      case result
      when Hash then klass.new(result.merge(overrides))
      else result
      end
    end
  
    def args(overrides)
      case block.arity
      when 1 then [MergingProxy.new(klass, overrides)]
      when 2 then [MergingProxy.new(klass, overrides), overrides]
      end
    end
  end
end