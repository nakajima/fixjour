module Fixjour
  module Counter
    def self.reset(key=nil)
      if key
        @counters[key] = lambda { s ||= 0; s += 1 }
      else
        @counters = Hash.new { |h,k| s ||= 0; c = lambda { s += 1 }; h[k] = c }
      end
    end
    reset

    def self.counter(key)
      @counters[key][]
    end

    def counter(key)
      Counter.counter(key)
    end
  end
end
