require 'rubygems'
require 'acts_as_fu'
require 'spec'
require 'rr'

require File.dirname(__FILE__) + '/../lib/fixjour'

include ActsAsFu

Spec::Runner.configure do |c|
  c.mock_with(:rr)
end

Spec::Runner.configuration.before(:each) do
  build_model(:foos) do
    string :name
    integer :age

    validates_presence_of :name
  end
end
