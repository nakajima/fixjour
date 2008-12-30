module Fixjour
  class << self
    def verify!
      builders.each do |klass|
        result = validity_checker.send("new_#{name_for(klass)}")
        
        unless result.valid?
          raise InvalidBuilder.new("The builder for #{klass} returns an invalid object")
        end
        
        unless result.new_record?
          raise BuilderSavedRecord.new("The builder for #{klass} must not save the object")
        end
        
        unless result.is_a?(klass)
          raise WrongBuilderType.new("The builder for #{klass} must return instance of #{klass}")
        end
      end
    end

    private

    def validity_checker
      @evaluator ||= begin
        klass = Class.new
        klass.send :include, self
        klass.new
      end
    end
  end
end