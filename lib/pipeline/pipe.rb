require_relative 'buildering'

module Pipeline
  class Pipe
    include Buildering
    def initialize(things_so_far = [])
      @do_these_things = things_so_far
    end

    def attach(piece)
      Pipe.new(@do_these_things + [piece])
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
