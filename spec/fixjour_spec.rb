require 'spec/spec_helper'

describe Fixjour do
  before(:each) do
    define_all_builders
  end
  
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

      context "passing a builder block" do
        it "returns a new model object" do
          new_foo.should be_kind_of(Foo)
        end

        it "is a new record" do
          new_foo.should be_new_record
        end

        it "returns defaults specified in block" do
          new_foo.name.should == 'Foo Namery'
        end

        it "merges overrides" do
          new_foo(:name => nil).name.should be_nil
        end
        
        it "allows access to other builders" do
          bar = new_bar
          mock(self).new_bar { bar }
          new_foo.bar.should == bar
        end
      end
      
      context "passing a hash" do
        it "returns a new model object" do
          new_bazz.should be_kind_of(Bazz)
        end

        it "is a new record" do
          new_bazz.should be_new_record
        end

        it "returns defaults specified in block" do
          new_bazz.name.should == 'Bazz Namery'
        end

        it "merges overrides" do
          new_bazz(:name => nil).name.should be_nil
        end
        
        it "does not allow access to other builders" do
          Fixjour.builders.delete(Bazz)
          proc {
            Fixjour do
              define_builder(Bazz, :bar => new_bar)
            end
          }.should raise_error(Fixjour::NonBlockBuilderReference)
        end
      end
    end
    
    describe "create_* methods" do
      it "calls new_* method then saves the result" do
        # mocking here to make sure it's still using the new_person helper
        # as opposed to calling Foo.new again. We don't want to duplicate
        # that sort of behavior
        mock(foo = Object.new).save!
        mock(self).new_foo { foo } 

        create_foo
      end
      
      context "declared with a block" do
        it "saves the record" do
          foo = create_foo
          foo.should_not be_new_record
        end

        it "retains defaults" do
          create_foo.name.should == 'Foo Namery'
        end

        it "still allows options override" do
          create_foo(:name => "created").name.should == "created"
        end
      end
      
      context "declated with a hash" do
        it "saves the record" do
          bazz = create_bazz
          bazz.should_not be_new_record
        end

        it "retains defaults" do
          create_bazz.name.should == 'Bazz Namery'
        end

        it "still allows options override" do
          create_bazz(:name => "created").name.should == "created"
        end
      end
    end
    
    describe "valid_*_attributes" do
      it "returns a hash containing the valid attributes specified in the builder" do
        valid_foo_attributes[:name].should == new_foo.name
      end

      it "does not include attributes that aren't defined in the builder block" do
        valid_foo_attributes.should_not have_key(:age)
      end

      it "allows overrides" do
        valid_foo_attributes(:name => "as attr")[:name].should == "as attr"
      end
      
      it "is indifferent" do
        valid_foo_attributes[:name].should == valid_foo_attributes['name']
      end
      
      it "memoizes valid model object" do
        mock.proxy(self).new_foo.once
        valid_foo_attributes
        valid_foo_attributes
        valid_foo_attributes
      end
      
      context "declared with a hash" do
        it "works the same way as builder block style" do
          valid_bazz_attributes[:name].should == new_bazz.name
        end
      end
    end
    
    describe "Fixjour.builders" do
      it "contains the classes for which there are builders" do
        Fixjour.should have(3).builders
        Fixjour.builders.should include(Foo, Bar, Bazz)
      end
      
      it "blows up when you try to define multiple builders for a class" do
        proc {
          Fixjour do
            define_builder(Foo) { |overrides| Foo.new(:name => 'bad!') }
          end
        }.should raise_error(Fixjour::RedundantBuilder)
      end
    end
    
    describe "Fixjour.verify!" do
      before(:each) do
        Fixjour.builders.delete(Foo)
      end
      
      context "when the builder returns an invalid object" do
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
  end
end
