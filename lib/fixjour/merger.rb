module Fixjour
  class Merger
    instance_methods.each { |m| undef_method(m) unless m =~ /__/ }
    
    def initialize(klass, overrides)
      @klass = klass
      @overrides = overrides
    end
  
    def new(defaults={})
      @klass.new(defaults.merge(@overrides))
    end
    
    def method_missing(sym, *args, &block)
      @klass.respond_to?(sym) ? @klass.send(sym, *args, &block) : super
    end
  end
end