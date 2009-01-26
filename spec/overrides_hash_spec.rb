require 'spec/spec_helper'

describe Fixjour::OverridesHash do
  attr_reader :overrides
  
  before(:each) do
    @overrides = Fixjour::OverridesHash.new(:name => "Pat")
  end
  
  it "inherits from Hash" do
    Fixjour::OverridesHash.superclass.should == Hash
  end
  
  describe "#process" do
    context "when the option isn't present" do
      it "doesn't do anything" do
        called = false
        overrides.process(:not_there) do
          called = true
        end
        called.should_not be
      end
      
      it "returns nil" do
        overrides.process(:not_there).should be_nil
      end
    end
    
    context "when the option is present" do
      it "deletes the option from the hash" do
        overrides.process(:name)
        overrides.should_not have_key(:name)
      end
      
      it "passes the value to the block" do
        overrides.process(:name) do |value|
          value.should == "Pat"
        end
      end
      
      it "allows values to be re-assigned in hash" do
        overrides.process(:name) do |value|
          overrides[:result] = value
        end
        overrides[:result].should == "Pat"
      end
      
      it "returns the value" do
        overrides.process(:name).should == "Pat"
      end
    end
  end
  
  describe "#delete" do
    it "is private" do
      proc {
        overrides.delete(:name)
      }.should raise_error(NoMethodError, /private/)
    end
  end
end