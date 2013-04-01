require_relative 'compound_result'
require_relative 'piece_common'

module Pipeline
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
end
