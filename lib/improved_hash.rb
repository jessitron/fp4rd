
class Hash
  def map_values &block
    self.reduce({}) {|h,(k,v)| h[k] =  block.call(v); h }
  end
end
