
class Hash
  def map_values &block
    result = Hash.new
    self.each_pair {|k,v| result[k] =  block.call(v) }
    result
  end
end
