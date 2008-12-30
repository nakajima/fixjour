$LOAD_PATH << File.dirname(__FILE__)

require 'rubygems'
require 'activerecord'
require 'core_ext/hash'
require 'fixjour/verify'
require 'fixjour/errors'
require 'fixjour/builders'

# This method is just for prettiness
def Fixjour(&block)
  return Fixjour unless block_given?
  Fixjour.module_eval(&block)
end
