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
      attach(take_function(how_many))
    end

    def keeping(predicate)
      attach(filter_function(predicate))
    end

    def through(transform)
      attach(map_function(transform))
    end

    def expand(transform)
      attach(expand_function(transform))
    end

    def split(paths)
      answer_int(JointPiece.new(paths))
    end

    module_function
    def take_function(how_many) # this will either return a Result or a Piece
      what_to_do = ->(piece, msg) do
        if (how_many == 0) then # this is a little inefficient. One extra piece of info will be read
          piece.send_eof
        else
          piece.pass_on(msg, take_function(how_many -1))
        end
      end
      what_to_do
    end

    def expand_function(expansion)
      ->(piece, msg) do
        next_piece = Inlet.new(piece.destination, :not_done).flow(expansion.call(msg))
        if (next_piece.result?) then
          next_piece
        else
          Piece.new(next_piece, expand_function(expansion))
        end
      end
    end

    def map_function(transform)
      ->(piece, msg) do
        piece.pass_on(transform.call(msg), map_function(transform))
      end
    end

    def filter_function(predicate)
      ->(piece, msg) do
        if(predicate.call(msg)) then
          piece.pass_on(msg, filter_function(predicate))
        else
          piece #don't change
        end
      end
    end
  end
end
