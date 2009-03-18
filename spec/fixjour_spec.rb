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

  describe "counter" do
    include Fixjour

    before(:each) do
      Fixjour::Counter.reset
    end

    it "provides default counter" do
      counter.should == 1
      counter.should == 2
      counter.should == 3
    end

    it "should increase" do
      counter(:foo).should == 1
      counter(:foo).should == 2
      counter(:foo).should == 3
    end

    it "should allow multiple counters" do
      counter(:foo).should == 1
      counter(:foo).should == 2
      counter(:bar).should == 1
      counter(:foo).should == 3
      counter(:bar).should == 2
    end

    it "should allow resetting a single counter" do
      counter(:foo).should == 1
      counter(:bar).should == 1
      Fixjour::Counter.reset :foo
      counter(:foo).should == 1
      counter(:bar).should == 2
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

      it "should raise a helpful error when the class can't be found" do
        lambda {
          Fixjour { define_builder(WhereOWhereAmI) }
        }.should raise_error(NameError)
      end

      context "passing a builder block with one arg" do
        context "when it returns a model object" do
          before(:each) do
            Fixjour.builders.delete(Foo)
            Fixjour do
              define_builder(Foo) do |klass|
                klass.new(:name => 'Foo Namery', :bar => new_bar)
              end
            end
          end

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

          it "is indifferent" do
            new_foo('name' => nil).name.should be_nil
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

        context "when passed a hash" do
          before(:each) do
            Fixjour.builders.delete(Foo)
            Fixjour do
              define_builder(Foo, :name => 'Foo Namery')
            end
          end

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
        end

        context "when it returns a hash" do
          before(:each) do
            Fixjour.builders.delete(Foo)
            Fixjour do
              define_builder(Foo) do |overrides|
                { :name => 'Foo Namery', :bar => new_bar }
              end
            end
          end

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
      end

      context "passing a builder block with two args" do
        before(:each) do
          Fixjour.builders.delete(Foo)
          Fixjour do
            define_builder(Foo) do |klass, overrides|
              klass.new({ :name => 'Foo Namery', :bar => new_bar })
            end
          end
        end

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

        it "is indifferent" do
          new_foo('name' => nil).name.should be_nil
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

      describe "returning new values every time" do
        before(:each) do
          FooBar.validates_uniqueness_of :name
          create_foo_bar(valid_foo_bar_attributes)
        end

        it "returns new values every time" do
          new_foo_bar(valid_foo_bar_attributes).should be_valid
        end
      end

      context "declared with a hash" do
        it "works the same way as builder block style" do
          valid_bazz_attributes[:name].should == new_bazz.name
        end
      end
    end

    describe "Fixjour.builders" do
      it "contains the classes for which there are builders" do
        Fixjour.should have(4).builders
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
        context "when :allow_redundancy is true" do
          before(:each) do
            Fixjour.builders.clear
          end

          it "doesn't blow up" do
            proc {
              Fixjour :allow_redundancy => true do
                define_builder(Bar) { Bar.new }
                define_builder(Bar) { Bar.new }
              end
            }.should_not raise_error
          end

          it "resets the settings when done" do
            Fixjour :allow_redundancy => true do
              define_builder(Bar) { Bar.new }
              define_builder(Bar) { Bar.new }
            end

            proc {
              Fixjour do
                define_builder(Bar) { Bar.new }
              end
            }.should raise_error(Fixjour::RedundantBuilder)
          end
        end

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

          it "raises RedundantBuilder for new_ when there's an underscore" do
            proc {
              self.class.class_eval do
                def new_foo_bar(overrides={}); end
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
                def valid_foo_attributes(overrides={}); end
              end
            }.should raise_error(Fixjour::RedundantBuilder)
          end
        end

        context "when the method is not redundant" do
          it "handles *similar* names" do
            proc {
              self.class.class_eval do
                def new_foo_source(overrides={}); end
                def choice_new_foo(overrides={}); end
              end
            }.should_not raise_error(Fixjour::RedundantBuilder)
          end

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

    describe "a virtual attribute" do
      before(:each) do
        Fixjour.builders.delete(Foo)
        Foo.class_eval { attr_accessor :bizzle }
        Fixjour do
          define_builder(Foo) do |klass, overrides|
            klass.new(:bizzle => 'fizzle')
          end
        end
      end

      it "gets preserved" do
        new_foo.bizzle.should == 'fizzle'
      end

      it "is overrideable" do
        new_foo(:bizzle => 'bliggety').bizzle.should == 'bliggety'
      end
    end

    describe "protected attributes" do
      before(:each) do
        Fixjour.builders.delete(Bar)
        Bar.attr_protected :name
        Fixjour do
          define_builder(Bar) do |klass, overrides|
            klass.protected :name
            klass.new :name => "Protect me!"
          end
        end
      end

      it "returns default value" do
        new_bar.name.should == "Protect me!"
      end

      it "can be overridden" do
        new_bar(:name => 'pwnd').name.should == 'pwnd'
      end
    end

    describe "processing overrides" do
      before(:each) do
        Fixjour.builders.delete(Foo)
      end

      context "when the builder block has one arg" do
        it "is raises DeprecatedMergeAttempt when #process is called" do
          proc {
            Fixjour.define_builder(Foo) do |overrides|
              overrides.process(:alias) { |v| overrides[:name] = v }
            end

            new_foo
          }.should raise_error(Fixjour::DeprecatedMergeAttempt)
        end
      end

      context "when the builder block has two args" do
        before(:each) do
          Fixjour do
            define_builder(Foo) do |klass, overrides|
              overrides.process(:alias) do |value|
                overrides[:name] = value
              end

              klass.new(:name => "El Nameo!")
            end
          end
        end

        it "returns a new Fixjour::OverridesHash" do
          mock.proxy(Fixjour::OverridesHash).new(:alias => "Bart Simpson")
          new_foo(:alias => "Bart Simpson")
        end

        it "merges overrides" do
          new_foo(:alias => "Bart Simpson").name.should == "Bart Simpson"
        end
      end
    end
  end
end
