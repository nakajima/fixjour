module Fixjour
  module Definitions
    # Defines the new_* method
    def define_new(klass, &block)
      define_method("new_#{name_for(klass)}") do |*args|
        Generator.new(klass, block).call(self, args.extract_options!.symbolize_keys!)
      end
    end
  
    # Defines the create_* method
    def define_create(name)
      define_method("create_#{name}") do |*args|
        model = send("new_#{name}", *args)
        model.save!
        model
      end
    end
  
    # Defines the valid_*_attributes method
    def define_valid_attributes(name)
      define_method("valid_#{name}_attributes") do |*args|
        valid_attributes = send("new_#{name}", *args).attributes
        valid_attributes.delete_if { |key, value| value.nil? }
        valid_attributes.stringify_keys!
        valid_attributes.make_indifferent!
        valid_attributes
      end
    end
  end
end