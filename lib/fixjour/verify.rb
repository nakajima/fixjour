module Fixjour
  class << self
    # Checks each builder to ensure that they:
    #
    # * Return valid objects
    # * The new_* methods return new records
    # * The creation methods return objects of the proper type
    def verify!
      builders.each do |klass|
        result = new_record(klass)

        unless result.valid?
          error(klass, InvalidBuilder, "returns an invalid object: #{result.errors.inspect}")
        end

        unless result.new_record?
          error(klass, BuilderSavedRecord, "must return a new record")
        end

        unless result.is_a?(klass)
          error(klass, WrongBuilderType, "must return an instance of #{klass}")
        end

        klass.transaction do
          begin
            result.save!
          rescue => e
            error(klass, UnsavableBuilder, "raises #{e.inspect} when saved to the database")
          end
        
          unless new_record(klass).valid?
            msg = ""
            msg << "returns invalid an invalid object after another object has been saved.\n"
            msg << "This could be caused by a validates_uniqueness_of validation in your model.\n"
            msg << "Use something like the faker gem to alleviate this issue."
            error(klass, DangerousBuilder, msg)
          end
          
          raise ActiveRecord::Rollback
        end
      end
    end

    def new_record(klass)
      evaluator.send("new_#{name_for(klass)}")
    end

    private

    def error(klass, exception, msg)
      raise exception.new("The builder for #{klass} #{msg} ")
    end
  end
end