module Fixjour
  class Counter
    class << self
      def reset(key=nil)
        key ? counters.delete(key) : counters.clear
      end

      def counter(key)
        counters[key] ||= new
        counters[key].next
      end

      private

      def counters
        @counters ||= {}
      end
    end

    reset

    def initialize
      @value = 0
    end

    def next
      @value += 1
    end
  end
end
