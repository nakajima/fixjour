require 'spec/spec_helper'

module Mister
  class Manager
    def initialize(attrs)
      @attributes = attrs
    end

    def valid?
      true
    end
  end
end

describe Fixjour, 'edge cases' do
  include Fixjour

  describe "namespaced models" do
    before(:each) do
      Fixjour.builders.clear
    end

    it "allows name to be specified" do
      Fixjour do
        define_builder(Mister::Manager, :as => :manager) do |klass|
          klass.new
        end
      end

      new_manager.should be_kind_of(Mister::Manager)
    end
  end
end
