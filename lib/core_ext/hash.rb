class Hash
  def make_indifferent!
    keys_values = self.dup
    indifferent = Hash.new { |h,k| h[k.to_s] if Symbol === k }
    replace(indifferent)
    merge!(keys_values)
  end
end