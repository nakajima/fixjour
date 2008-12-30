module Fixjour
  class << self
    def verify!
      builders.each do |klass|
        result = validity_checker.send("new_#{name_for(klass)}")
        unless result.is_a?(klass) and result.valid?
          raise InvalidBuilder.new("The builder for #{klass} returns an invalid object.")
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