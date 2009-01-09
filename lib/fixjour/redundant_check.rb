module Fixjour
  def self.included(klass)
    klass.extend(RedundancyChecker)
  end
  
  # Uses method_added hook to make sure no redundant builder methods
  # get defined after a builder has already created them. For example,
  # if you have a Comment builder, this hook will ensure that any attempt
  # to define a #new_comment method will raise an exception.
  module RedundancyChecker
    BUILDER_METHOD_PATTERN = /^(new|create|valid)_(\w+)(_attributes)?$/
    
    def method_added(sym)
      name = sym.to_s
      
      if klass_name = get_klass_name(name)
        if Fixjour.builder_defined?(klass_name)
          raise RedundantBuilder.new("You already defined a builder for #{inspect}")
        end
      end
    end
    
    def get_klass_name(name)
      if match = name.match(BUILDER_METHOD_PATTERN)
        match[2].classify.gsub(/Attribute$/, '')
      end
    end
  end
end