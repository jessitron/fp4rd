
class PipelineBuilder
  def initialize(source)
    @source = source
  end

  def answer(monoid)
    Inlet.new(@source, EndPiece.new(monoid))
  end
end

class Inlet
  def initialize(source, nextPiece)
    @source = source.each #iterator
    @nextPiece = nextPiece
  end

  def flow
    result = begin
      Inlet.new(@source, @nextPiece.receive(@source.next)).flow
    rescue StopIteration
      @nextPiece.eof
    end
  end

end

module Piece

end

class EndPiece
  include Piece
  def initialize(monoid)
    @monoid = monoid
    @soFar = monoid.zero
  end

  def eof
    Result.new(@soFar)
  end

  def receive msg
    @soFar = @monoid.append(@soFar, msg)
    self
  end
end


class Monoid
  attr_reader :zero
  def initialize(zero, add_lambda)
    @zero = zero
    @append = add_lambda
  end
  def append(a,b)
    @append.call(a,b)
  end
  def self.concat
    Monoid.new("", ->(a,b) {a + b})
  end
end

class Result
  attr_reader :value
  def initialize(value)
    @value = value
  end
end

