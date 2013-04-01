require_relative 'piece_common'
require_relative 'simple_result'

module Pipeline
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
end
