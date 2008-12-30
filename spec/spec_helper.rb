require 'rubygems'
require 'spec'
require 'rr'

begin
  require 'acts_as_fu'
rescue LoadError
  puts "You need the acts_as_fu gem to run the specs."
  exit!
end

require File.dirname(__FILE__) + '/../lib/fixjour'

Spec::Runner.configure do |c|
  c.mock_with(:rr)
end

include ActsAsFu

build_model(:foos) do
  string :name
  integer :age
  integer :foo_id

  belongs_to :bar

  validates_presence_of :name
end

build_model(:bars) do
  string :name
end

build_model(:bazzs) do
  string :name
end
