require_relative 'piece_common'
require_relative 'simple_result'

module Pipeline
  class EndPiece
    include PieceCommon
    def initialize(monoid, soFar = :no_value)
      @monoid = monoid
      @soFar = (soFar == :no_value) ? monoid.zero : soFar
    end

    def eof
      SimpleResult.new(@soFar)
    end

    def receive msg
      EndPiece.new(@monoid, @monoid.append(@soFar, msg))
    end
  end
end
