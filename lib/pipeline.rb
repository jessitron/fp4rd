require_relative 'improved_hash'


module Buildering
  def answer(monoid)
    answer_int(EndPiece.new(monoid))
  end

  def count
    answer_int(CountingEndPiece.new)
  end

  def take(how_many)
    @do_these_things.push(takeFunction(how_many))
    self
  end

  def keeping(predicate)
    @do_these_things.push(filterFunction(predicate))
    self
  end

  def through(transform)
    @do_these_things.push(mapFunction(transform))
    self
  end

  def expand(transform)
    @do_these_things.push(expandFunction(transform))
    self
  end

  def split(paths)
    answer_int(JointPiece.new(paths))
  end

  module_function
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
      nextPiece = Inlet.new(piece.destination, :not_done).flow(expansion.call(msg))
      if (nextPiece.result?) then
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

end

class Pipe
  include Buildering
  def initialize
    @do_these_things = []
  end

  def answer_int(piece)
    if (@do_these_things.empty?)
      piece
    else
      answer_int(Piece.new(piece, @do_these_things.pop))
    end
  end
end

module PieceCommon
  def flow(source)
     Inlet.new(self).flow_internal(source.each)
  end
  def result?
    false
  end
end

class JointPiece
  def initialize(paths)
    @paths = paths
  end
  include PieceCommon

  def receive(msg)
    go = ->(v) { v.result? ? v : v.receive(msg) }
    newMap = @paths.map_values(&go)
    if (newMap.values.all? &:result? )
      construct_compound_result(newMap)
    else
      JointPiece.new(newMap)
    end
  end

  def eof
    go = ->(v) { v.result? ? v : v.eof }
    newMap = @paths.map_values(&go)
    construct_compound_result(newMap)
  end

  private
  def construct_compound_result(paths)
    CompoundResult.new(paths)
  end
end

module Result
  def result?
    true
  end
end

class CompoundResult
  include Result
  def initialize(paths)
    @contents = paths
  end

  def value(*path)
    return self if path.empty?
    (head, *tail) = path
    puts "Nothing found at #{head}" unless @contents[head]
    @contents[head].value(*tail)
  end
end

class Piece
  attr_reader :destination
  include PieceCommon

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
  def initialize(nextPiece, done_or_not = :done)
    @nextPiece = nextPiece
    @done_or_not = done_or_not
  end

  def flow(source)
    flow_internal(source.each)
  end

  def flow_internal(source)
    result = begin
      response = @nextPiece.receive(source.next)
      if (response.result?) then
        response
      else #it's another piece
        Inlet.new(response, @done_or_not).flow_internal(source)
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

class CountingEndPiece
  include PieceCommon
  def initialize(soFar = 0)
    @soFar = soFar
  end
  def eof
    SimpleResult.new(@soFar)
  end
  def receive msg
    CountingEndPiece.new(@soFar + 1)
  end
end

class EndPiece
  include PieceCommon
  def initialize(monoid)
    @monoid = monoid
    @soFar = monoid.zero
  end

  def eof
    SimpleResult.new(@soFar)
  end

  def receive msg
    @soFar = @monoid.append(@soFar, msg) #could easily be made stateless
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


class SimpleResult
  include Result
  def initialize(value)
    @value = value
  end

  def value
    @value
  end
end

