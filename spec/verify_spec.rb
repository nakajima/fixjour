require 'spec/spec_helper'

describe Fixjour, ".verify!" do
  before(:each) do
    define_all_builders
    Fixjour.builders.clear
  end

  it "can take verify as an option" do
    mock(Fixjour).verify!.once
    Fixjour(:verify => true) { }
  end
  
  describe "clearing the transaction" do
    before(:each) do
      Fixjour do
        define_builder(Foo) { |overrides| Foo.new(:name => 'ok', :bar => new_bar) }
      end
    end
    
    it "rolls back the transaction" do
      proc {
        Fixjour.verify!
      }.should_not change(Foo, :count)
    end
  end

  context "when the builder returns an invalid object" do
    context "when the validations are not related to uniqueness" do
      before(:each) do
        Fixjour do
          define_builder(Foo) { |overrides| Foo.new(:bar => nil) }
        end
      end
      
      it "raises InvalidBuilder" do
        proc {
          Fixjour.verify!
        }.should raise_error(Fixjour::InvalidBuilder)
      end

      it "includes information about the failure" do
        proc {
          Fixjour.verify!
        }.should raise_error(/BAR AIN'T THURR/)
      end
    end
    
    context "when the validations are related to uniqueness" do
      before(:each) do
        Bar.delete_all
        Bar.validates_uniqueness_of :name
        Fixjour do
          define_builder(Bar) { |overrides| Bar.new(:name => "percy") }
        end
      end
      
      it "raises DangerousBuilder" do
        proc {
          Fixjour.verify!
        }.should raise_error(Fixjour::DangerousBuilder)
      end

      it "includes information about the failure" do
        proc {
          Fixjour.verify!
        }.should raise_error(/uniqueness/)
      end
    end
  end
  
  context "when the builder returns an object that cannot be saved" do
    before(:each) do
      Fixjour.builders.clear

      klass = build_model(:bars) { string :name }
      
      bar_bomb = Object.new
      stub(bar_bomb).save! { raise ActiveRecord::StatementInvalid.new("oops!") }
      stub(bar_bomb).valid? { true }
      stub(bar_bomb).new_record? { true }
      stub(bar_bomb).is_a?(Bar) { true }
      
      stub(Fixjour).new_record(Bar) { bar_bomb }
      
      Fixjour do
        define_builder(klass) { |overrides| klass.new }
      end
    end
    
    it "raises UnsavableBuilder" do
      proc {
        Fixjour.verify!
      }.should raise_error(Fixjour::UnsavableBuilder)
    end
    
    it "includes information about the failure" do
      proc {
        Fixjour.verify!
      }.should raise_error(/ActiveRecord::StatementInvalid/)
    end
  end

  context "when the builder saves the object" do
    before(:each) do
      Fixjour do
        define_builder(Foo) do |overrides|
          Foo.create(:name => 'saved!', :bar => new_bar)
        end
      end
    end

    it "raises BuilderSavedRecord" do
      proc {
        Fixjour.verify!
      }.should raise_error(Fixjour::BuilderSavedRecord)
    end
  end

  context "when the object is not the correct type" do
    before(:each) do
      Fixjour do
        define_builder(Foo) { |overrides| Bar.new(:name => 'saved!') }
      end
    end

    it "raises WrongBuilderType" do
      proc {
        Fixjour.verify!
      }.should raise_error(Fixjour::WrongBuilderType)
    end
  end
end