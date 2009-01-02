$LOAD_PATH << File.dirname(__FILE__)

require 'rubygems'
require 'activerecord'
require 'core_ext/hash'
require 'fixjour/redundant_check'
require 'fixjour/verify'
require 'fixjour/errors'
require 'fixjour/builders'

# This method is just for prettiness
def Fixjour(options={}, &block)
  return Fixjour unless block_given?
  Fixjour.evaluate(&block)
  Fixjour.verify! if options[:verify]
end
