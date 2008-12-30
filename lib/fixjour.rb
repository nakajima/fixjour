$LOAD_PATH << File.dirname(__FILE__)

require 'rubygems'
require 'activerecord'
require 'core_ext/hash'

module Fixjour
  # This method should always return a valid instance of
  # a model object.
  def self.define_builder(klass, &block)
    name = klass.model_name.singular
    
    define_method("new_#{name}") do |*args|
      overrides = args.first || { }
      block.bind(self).call(overrides)
    end

    define_method("create_#{name}") do |*args|
      model = send("new_#{name}", *args)
      model.save!
      model
    end

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

# This method is just for prettiness
def Fixjour(&block)
  return Fixjour unless block_given?
  Fixjour.module_eval(&block) if block_given?
end
