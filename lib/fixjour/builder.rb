module Fixjour
  class Builder
    attr_reader :klass

    def initialize(klass, options={})
      @klass, @options = klass, options
    end

    def name
      @name ||= (@options[:as] || @klass.name.underscore).to_s.gsub(/\W+/, '_')
    end

    def eql?(other)
      @klass == other.klass
    end

    def hash
      @klass.hash
    end
  end
end
