require_relative 'buildering'

module Pipeline
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
end
