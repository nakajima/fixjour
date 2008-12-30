require 'spec/spec_helper'

Fixjour do
  define_builder(:foo) do |options|
    Foo.new({ :name => 'Foo' }.merge(options))
  end
  
  define_builder(:bar) do |options|
    Bar.new
  end
end

describe Fixjour do
  describe "when Fixjour is not included" do
    it "does not have access to creation methods" do
      self.should_not respond_to(:new_foo)
    end
  end
  
  describe "when Fixjour is included" do
    include Fixjour
    
    describe "new_* methods" do
      it "generates new_[model] method" do
        proc {
          new_foo
        }.should_not raise_error
      end

      it "returns result of block object" do
        new_foo.should be_kind_of(Foo)
      end

      it "merges overrides" do
        new_foo(:name => nil).name.should be_nil
      end
    end
  end
end