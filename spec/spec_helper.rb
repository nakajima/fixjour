require 'spec'
require 'faker'
require 'rr'

begin
  require 'acts_as_fu'
rescue LoadError
  puts "You need the acts_as_fu gem to run the specs."
  exit!
end

require File.dirname(__FILE__) + '/../lib/fixjour'

Spec::Runner.configure do |c|
  c.mock_with(:rr)
end

include ActsAsFu

build_model(:foos) do
  attr_accessor :bizzle

  string :name
  integer :age
  integer :bar_id
  integer :person_id

  belongs_to :bar
  belongs_to :owner, :foreign_key => :person_id, :class_name => 'Person'

  validates_presence_of :bar, :message => "BAR AIN'T THURR"
  validates_presence_of :name
end

build_model(:bars) do
  string :name
end

build_model(:bazzs) do
  string :name
  integer :bar_id

  belongs_to :bar
end

build_model(:foo_bars) do
  string :name
end

build_model(:people) do
  string :first_name
  string :last_name
end

def define_all_builders
  Fixjour.builders.clear
  Fixjour do
    define_builder(Foo) do |klass, overrides|
      klass.new({ :name => 'Foo Namery', :bar => new_bar, :owner => new_person }.merge(overrides))
    end

    define_builder(Bar) do |klass, overrides|
      klass.new({ :name => "Bar Namery" }.merge(overrides))
    end

    define_builder(FooBar) do |klass, overrides|
      klass.new(:name => "foobar-#{counter(:foobar)}")
    end

    define_builder(Bazz) do |klass|
      klass.new(:name => "Bazz Namery")
    end
    
    define_builder Person do |klass|
      klass.new
    end
  end
end
