module Fixjour
  class << self
    def builders
      @builders ||= Set.new
    end

    def add_builder(klass)
      unless builders.add?(klass)
        raise RedundantBuilder.new("You already defined a builder for #{klass.inspect}")
      end
    end
    
    # This method should always return a valid instance of
    # a model object.
    def define_builder(klass, &block)
      add_builder(klass)

      name = name_for(klass)

      define_new(name, block)
      define_create(name)
      define_valid_attributes(name)
    end
    
    private

    def name_for(klass)
      klass.model_name.singular
    end
    
    def define_new(name, block)
      define_method("new_#{name}") do |*args|
        overrides = args.first || { }
        block.bind(self).call(overrides)
      end
    end
    
    def define_create(name)
      define_method("create_#{name}") do |*args|
        model = send("new_#{name}", *args)
        model.save!
        model
      end
    end
    
    def define_valid_attributes(name)
      define_method("valid_#{name}_attributes") do |*args|
        if instance_variable_get("@__valid_#{name}_attrs").nil?
          valid_attributes = send("new_#{name}").attributes
          valid_attributes.delete_if { |key, value| value.nil? }
          instance_variable_set("@__valid_#{name}_attrs", valid_attributes)
        end

        overrides = args.extract_options!
        attrs = instance_variable_get("@__valid_#{name}_attrs").merge(overrides)
        attrs.make_indifferent!
        attrs
      end
    end
  end
end