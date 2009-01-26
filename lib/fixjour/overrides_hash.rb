module Fixjour
  # The overrides hash passed into each of the Fixjour
  # methods is wrapped in this class to make the delete
  # method private and add the ability to process.
  class OverridesHash < Hash
    private :delete
    
    def initialize(hash)
      replace(hash)
    end
    
    # Allows for processing of the overrides hash. Deletes
    # the option when it's present, then yields the value.
    def process(option)
      delete(option).tap do |value|
        yield value if value and block_given?
      end
    end
  end
end