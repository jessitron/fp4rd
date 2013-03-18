
class PipelineBuilder
  def initialize(source)
    @source = source
    @doTheseThings = []
  end

  def take(how_many)
    @doTheseThings.push(takeFunction(how_many))
    self
  end

  def keeping(predicate)
    @doTheseThings.push(filterFunction(predicate))
    self
  end

  def through(transform)
    @doTheseThings.push(mapFunction(transform))
    self
  end

  def answer(monoid)
    answer_int(EndPiece.new(monoid))
  end

  def expand(transform)
    @doTheseThings.push(expandFunction(transform))
    self
  end

  # private below here
  def takeFunction(how_many) # this will either return a Result or a Piece
    what_to_do = ->(piece, msg) do
      if (how_many == 0) then # this is a little inefficient. One extra piece of info will be read
        piece.sendEof
      else
        piece.passOn(msg, takeFunction(how_many -1))
      end
    end
    what_to_do
  end

  def expandFunction(expansion)
    ->(piece, msg) do
      nextPiece = Inlet.new(expansion.call(msg), piece.destination, :not_done).flow()
      if (nextPiece.is_a? Result) then
        nextPiece
      else
        Piece.new(nextPiece, expandFunction(expansion))
      end
    end
  end

  def mapFunction(transform)
    ->(piece, msg) do
      piece.passOn(transform.call(msg), mapFunction(transform))
    end
  end

  def filterFunction(predicate)
    ->(piece, msg) do
      if(predicate.call(msg)) then
        piece.passOn(msg, filterFunction(predicate))
      else
        piece #don't change
      end
    end
  end

  def answer_int(piece)
    if (@doTheseThings.empty?)
      Inlet.new(@source, piece)
    else
      answer_int(Piece.new(piece, @doTheseThings.pop))
    end
  end
end

class Piece
  attr_reader :destination
  def initialize(destination, what_to_do)
    @destination = destination
    @what_to_do = what_to_do
  end
  def receive(msg)
    @what_to_do.call(self, msg)
  end
  def eof
    sendEof
  end
  def passOn(msg, what_to_do_next)
    next_destination = @destination.receive(msg)
    Piece.new(next_destination, what_to_do_next)
  end
  def sendEof
    @destination.eof
  end
end


class Inlet
  def initialize(source, nextPiece, done_or_not = :done)
    @source = source.each #iterator
    @nextPiece = nextPiece
    @done_or_not = done_or_not
  end

  def flow
    result = begin
      response = @nextPiece.receive(@source.next)
      if (response.is_a? Result) then
        response
      else #it's another piece
        Inlet.new(@source, response, @done_or_not).flow
      end
    rescue StopIteration
      if (@done_or_not == :done) then
        @nextPiece.eof
      else
        @nextPiece
      end
    end
  end

end

class EndPiece
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

  # instances
  def self.concat
    Monoid.new("", ->(a,b) {a + b})
  end
  def self.plus
    Monoid.new(0,  ->(a,b) {a + b})
  end
end

class Result
  attr_reader :value
  def initialize(value)
    @value = value
  end
end

