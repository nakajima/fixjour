require 'rubygems'
require 'nakajima'

module Fixjour
  def self.define_builder(name, &block)
    define_method("new_#{name}") do |*args|
      overrides = args.first || { }
      block.call(overrides)
    end
  end
end

# This method is just for prettiness
def Fixjour(&block)
  return Fixjour unless block_given?
  Fixjour.module_eval(&block) if block_given?
end