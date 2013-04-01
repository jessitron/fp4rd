require_relative 'counting_end_piece'
require_relative 'end_piece'
require_relative 'inlet'
require_relative 'joint_piece'
require_relative 'piece'

module Pipeline
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
end
