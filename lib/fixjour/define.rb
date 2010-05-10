module Fixjour
  def self.define(object, options={}, &block)
    if builder = options[:from]
      name = builder.is_a?(Symbol) ? builder : Fixjour.send(:name_for, builder)
      Fixjour.define_builder(builder, :as => object) do |klass, overrides|
        # klass is NOT to be used in this case
        instance = send("new_#{name}")
        instance_exec(instance, &block)
        overrides.each { |key, val| instance[key] = val }
        instance
      end
    else
      Fixjour.define_builder(object, options) do |klass, overrides|
        instance = klass.new
        instance_exec(instance, &block)
        overrides.each { |key, val| instance[key] = val }
        instance
      end
    end
  end
end