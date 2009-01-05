module Fixjour
  # Raised when a builder is defined for a class that already
  # has one.
  class RedundantBuilder < StandardError; end
  
  def self.included(klass)
    klass.extend(RedundancyChecker)
  end
  
  def self.builder_defined?(builder)
    case builder
    when Class          then builders.include?(builders)
    when String, Symbol then builders.map(&:name).include?(builder)
    end
  end
  
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