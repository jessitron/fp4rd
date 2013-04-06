require_relative 'piece_common'

module Pipeline
  class CountingEndPiece
    include PieceCommon
    def initialize(so_far = 0)
      @so_far = so_far
    end
    def eof
      SimpleResult.new(@so_far)
    end
    def receive msg
      CountingEndPiece.new(@so_far + 1)
    end
  end
end
