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

def Fixjour(&block)
  return Fixjour unless block_given?
  include Fixjour
  Fixjour.instance_eval(&block) if block_given?
end