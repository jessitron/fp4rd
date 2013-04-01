require_relative 'piece_common'

module Pipeline
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
end
