require_relative 'piece_common'
require_relative 'simple_result'

module Pipeline
  class EndPiece
    include PieceCommon
    def initialize(monoid, so_far = :no_value)
      @monoid = monoid
      @so_far = (so_far == :no_value) ? monoid.zero : so_far
    end

    def eof
      SimpleResult.new(@so_far)
    end

    def receive msg
      EndPiece.new(@monoid, @monoid.append(@so_far, msg))
    end
  end
end
