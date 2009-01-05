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
        
        it "can be made invalid associated objects" do
          new_foo(:bar => nil).should_not be_valid
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
      
      context "declared with a hash" do
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
      
      it "overrides indifferently" do
        valid_foo_attributes("name" => "as attr")[:name].should == "as attr"
        valid_foo_attributes(:name => "as attr")["name"].should == "as attr"
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
      
      context "when defining multiple builders for same class" do
        it "raises RedundantBuilder error" do
          proc {
            Fixjour do
              define_builder(Foo) { |overrides| Foo.new(:name => 'bad!') }
            end
          }.should raise_error(Fixjour::RedundantBuilder)
        end
      end
      
      describe "redundancy checker" do
        describe "method_added hook" do
          context "when it's already defined for the class" do
            before(:each) do
              @klass = Class.new do
                def self.added_methods
                  @added_methods ||= []
                end
                
                def self.method_added(name)
                  added_methods << name
                end
                
                include Fixjour
              end
            end
            
            it "does not lose old behavior" do
              @klass.class_eval { def foo; :foo end }
              @klass.added_methods.should include(:foo)
            end
            
            it "gets Fixjour behavior" do
              foo = @klass.new.new_foo
              foo.should be_kind_of(Foo)
            end
          end
        end
        
        context "when the method is redundant" do
          it "raises RedundantBuilder for new_*" do
            proc {
              self.class.class_eval do
                def new_foo(overrides={}); Foo.new end
              end
            }.should raise_error(Fixjour::RedundantBuilder)
          end
          
          it "raises RedundantBuilder for create_*" do
            proc {
              self.class.class_eval do
                def create_foo(overrides={}); Foo.new end
              end
            }.should raise_error(Fixjour::RedundantBuilder)
          end
          
          it "raises RedundantBuilder for valid_*_attributes" do
            proc {
              self.class.class_eval do
                def valid_foo_attributes(overrides={}); Foo.new end
              end
            }.should raise_error(Fixjour::RedundantBuilder)
          end
        end
        
        context "when the method is not redundant" do
          it "does not raise error" do
            proc {
              self.class.class_eval do
                def valid_nothing_attributes(overrides={}); Foo.new end
              end
            }.should_not raise_error
          end
        end
      end
    end
    
    describe "Fixjour.verify!" do
      before(:each) do
        Fixjour.builders.delete(Foo)
      end
      
      it "can take verify as an option" do
        mock(Fixjour).verify!.once
        Fixjour(:verify => true) { }
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
        
        it "includes information about the failure" do
          proc {
            Fixjour.verify!
          }.should raise_error(/BAR AIN'T THURR/)
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
    
    describe "processing overrides" do
      before(:each) do
        Fixjour do
          define_builder(Person) do |overrides|
            overrides.process(:name) do |name|
              split = name.split(' ')
              overrides[:first_name]  = split[0]
              overrides[:last_name]   = split[1]
            end
            
            Person.new(overrides)
          end
        end
      end

      it "allows overrides hash to be processed" do
        person = new_person(:name => "Bart Simpson")
        person.first_name.should == "Bart"
        person.last_name.should == "Simpson"
      end
    end
  end
end
