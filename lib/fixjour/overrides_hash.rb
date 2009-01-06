module Fixjour
  class OverridesHash < Hash
    private :delete
    
    def initialize(hash)
      replace(hash)
    end
    
    def process(option)
      if value = delete(option)
        yield value if block_given?
      end
    end
  end
end