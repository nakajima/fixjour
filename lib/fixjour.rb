$LOAD_PATH << File.dirname(__FILE__)

require 'rubygems'
require 'activerecord'
require 'core_ext/hash'
require 'fixjour/merging_proxy'
require 'fixjour/redundant_check'
require 'fixjour/overrides_hash'
require 'fixjour/verify'
require 'fixjour/errors'
require 'fixjour/builders'

module Fixjour
  # Raised when a builder returns an invalid object
  class InvalidBuilder < StandardError; end
  
  # Raised when a builder returns an object of the wrong type
  class WrongBuilderType < StandardError; end
  
  # Raised when a builder block saves the object.
  class BuilderSavedRecord < StandardError; end
  
  # Raised when a Fixjour creation method is called in
  # the wrong context.
  class NonBlockBuilderReference < StandardError; end
end

# This method is just for prettiness
def Fixjour(options={}, &block)
  return Fixjour unless block_given?
  Fixjour.allow_redundancy = options[:allow_redundancy]
  Fixjour.evaluate(&block)
  Fixjour.verify! if options[:verify]
  Fixjour.allow_redundancy = false
end
