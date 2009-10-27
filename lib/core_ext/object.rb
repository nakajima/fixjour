unless respond_to?(:tap)
  class Object
    def tap
      yield self
      self
    end
  end
end