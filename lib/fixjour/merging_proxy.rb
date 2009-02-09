module Fixjour
  # Proxy passed to builder blocks as first argument when a builder
  # block takes two arguments. Automatically merges overrides when
  # the #new method is called.
  class MergingProxy
    instance_methods.each { |m| undef_method(m) unless m =~ /__|inspect/ }
    
    def initialize(klass, overrides)
      @klass = klass
      @overrides = overrides
    end
    
    def protected(*attrs)
      attrs = attrs.empty? ?
        @protected :
        @protected = attrs
      Set.new(attrs)
    end
  
    def new(defaults={})
      attrs = defaults.merge(@overrides)
      accessible, inaccessible = partition(attrs)
      
      returning @klass.new(accessible) do |instance|
        inaccessible.each do |key,val|
          instance.send("#{key}=", val)
        end
      end
    end
    
    def method_missing(sym, *args, &block)
      @klass.respond_to?(sym) ? @klass.send(sym, *args, &block) : super
    end
    
    private
    
    def partition(attrs)
      accessible = attrs.keys.inject({ }) do |m, key|
        next m if protected.include?(key)
        m[key] = attrs.delete(key)
        m
      end
      [accessible, attrs]
    end
  end
end