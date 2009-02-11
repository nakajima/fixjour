module Fixjour
  def succ
    Counter.count += 1
  end
  
  module_function :succ
  
  module Counter
    class << self
      attr_writer :count
    end
    
    def self.count
      @count ||= 0
    end
    
    def count
      Counter.count
    end
  end
end