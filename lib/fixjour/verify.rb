module Fixjour
  class << self
    # Checks each builder to ensure that they:
    #
    # * Return valid objects
    # * The new_* methods return new records
    # * The creation methods return objects of the proper type
    def verify!
      builders.each do |klass|
        result = evaluator.send("new_#{name_for(klass)}")
        
        unless result.valid?
          raise InvalidBuilder.new("The builder for #{klass} returns an invalid object: #{result.errors.inspect}")
        end
        
        unless result.new_record?
          raise BuilderSavedRecord.new("The builder for #{klass} must not save the object")
        end
        
        unless result.is_a?(klass)
          raise WrongBuilderType.new("The builder for #{klass} must return instance of #{klass}")
        end
      end
    end
  end
end