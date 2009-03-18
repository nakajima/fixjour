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

  describe "protected" do
    it "stores the protected attributes" do
      @merger.protected :name
      @merger.protected.should == Set.new([:name])
    end

    it "sends values to instance" do
      mock.proxy(Foo).new(:name => "MERGED!").never
      mock.proxy(Foo).new({ }).once
      @merger.protected :name
      @merger.new(:name => "MERGED!").name.should == "MERGED!"
    end
  end

  describe "proxying to klass" do
    it "proxies other methods to klass" do
      merger.superclass.should == ActsAsFu::Connection
    end

    it "proxies respond_to? to klass" do
      merger.should respond_to(:superclass)
    end

    it "should keep its own inspect method" do
      merger.inspect.should_not == Foo.inspect
    end
  end
end
