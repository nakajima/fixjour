$LOAD_PATH << File.dirname(__FILE__)

require 'rubygems'
require 'activerecord'
require 'core_ext/hash'
require 'core_ext/object'
require 'fixjour/merging_proxy'
require 'fixjour/redundant_check'
require 'fixjour/overrides_hash'
require 'fixjour/verify'
require 'fixjour/errors'
require 'fixjour/generator'
require 'fixjour/definitions'
require 'fixjour/counter'
require 'fixjour/builders'
require 'fixjour/deprecation'

# This method is just for prettiness
def Fixjour(options={}, &block)
  return Fixjour unless block_given?
  Fixjour.allow_redundancy = options[:allow_redundancy]
  Fixjour.evaluate(&block)
  Fixjour.verify! if options[:verify]
  Fixjour.allow_redundancy = false
end
