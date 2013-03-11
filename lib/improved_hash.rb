
class Hash
  def map_values &block
    self.each_with_object({}) {|(k,v), h| h[k] = block.call(v) }
  end
end
