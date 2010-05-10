require 'spec/spec_helper'

describe Fixjour, '.define' do
  include Fixjour

  before(:each) do
    Fixjour.builders.clear
  end

  it "defines a valid builder" do
    Fixjour.define(Person) do |person|
      person.first_name = 'Pat'
    end

    person = new_person
    person.first_name.should == 'Pat'

    new_person(:first_name => 'Larry').first_name.should == 'Larry'

    created_person = create_person
    created_person.should_not be_new_record
    created_person.first_name.should == 'Pat'
  end

  it "allows 'scenario' builders from class name" do
    Fixjour.define(Person) do |person|
      person.first_name = 'Pat'
    end

    Fixjour.define(:person_with_last_name, :from => Person) do |person|
      person.last_name = 'Nakajima'
    end

    new_person_with_last_name.first_name.should == 'Pat'
    new_person_with_last_name.last_name.should == 'Nakajima'
  end

  it "allows 'scenario' builders from other scenario" do
    Fixjour.define(Person) do |person|
      person.first_name = 'Pat'
    end

    Fixjour.define(:person_with_last_name, :from => Person) do |person|
      person.last_name = 'Nakajima'
    end

    Fixjour.define(:person_with_bar_id, :from => :person_with_last_name) do |person|
      person.bar_id = 123
    end

    new_person_with_bar_id.first_name.should == 'Pat'
    new_person_with_bar_id.last_name.should == 'Nakajima'
    new_person_with_bar_id.bar_id.should == 123
  end
end
