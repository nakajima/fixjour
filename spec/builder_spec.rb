require File.dirname(__FILE__) + '/spec_helper'

describe Fixjour::Builder do
  def new_builder(*args)
    Fixjour::Builder.new(*args)
  end

  it "takes a class" do
    new_builder(Foo).klass.should == Foo
  end

  it "can have a name specified" do
    new_builder(Foo, :as => :fooz).name.should == 'fooz'
  end

  it "can infer name" do
    new_builder(Foo).name.should == 'foo'
  end

  it "can infer nested name" do
    class Foo; class Bar; end end
    new_builder(Foo::Bar).name.should == 'foo_bar'
  end
end
