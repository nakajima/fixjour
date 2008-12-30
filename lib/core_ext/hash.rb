class Hash
  # Makes a hash able to be accessed via symbol or string keys.
  def make_indifferent!
    keys_values = self.dup
    indifferent = Hash.new { |h,k| h[k.to_s] if Symbol === k }
    replace(indifferent)
    merge!(keys_values)
  end
end