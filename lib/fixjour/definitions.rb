module Fixjour
  module Definitions
    # Defines the new_* method
    def define_new(builder, &block)
      define_method("new_#{builder.name}") do |*args|
        Generator.new(builder.klass, block).call(self, args.extract_options!.symbolize_keys!)
      end
    end

    # Defines the create_* method
    def define_create(builder)
      define_method("create_#{builder.name}") do |*args|
        model = send("new_#{builder.name}", *args)
        model.save!
        model
      end
    end

    # Defines the valid_*_attributes method
    def define_valid_attributes(builder)
      define_method("valid_#{builder.name}_attributes") do |*args|
        valid_attributes = send("new_#{builder.name}", *args).attributes
        valid_attributes.delete_if { |key, value| value.nil? }
        valid_attributes.stringify_keys!
        valid_attributes.make_indifferent!
        valid_attributes
      end
    end
  end
end
