require 'rubygems'
require 'acts_as_fu'
require 'spec'
require 'rr'

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
