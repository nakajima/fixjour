module Fixjour
  class Merger
    def initialize(klass, overrides)
      @klass = klass
      @overrides = overrides
    end
  
    def new(defaults={})
      @klass.new(defaults.merge(@overrides))
    end
  end
end