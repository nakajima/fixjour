require 'spec/spec_helper'

describe Fixjour::MergingProxy do
  attr_reader :merger
  
  before(:each) do
    @merger = Fixjour::MergingProxy.new(Foo, :name => "MERGED!")
  end
  
  describe "#new" do
    it "merges options with overrides" do
      mock.proxy(defaults = { :name => "Pat" }).merge(:name => "MERGED!")
      merger.new(defaults)
    end
    
    it "returns an instance of the klass with the merged options" do
      merger.new(:name => "Pat").should be_kind_of(Foo)
    end
  end

  describe "proxying to klass" do
    it "proxies other methods to klass" do
      merger.superclass.should == ActiveRecord::Base
    end
    
    it "proxies respond_to? to klass" do
      merger.should respond_to(:superclass)
    end
    
    it "should keep its own inspect method" do
      merger.inspect.should_not == Foo.inspect
    end
  end
end