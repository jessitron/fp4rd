require_relative 'piece_common'

module Pipeline
  class Piece
    attr_reader :destination
    include PieceCommon

    def initialize(destination, what_to_do)
      @destination = destination
      @what_to_do = what_to_do
    end

    def receive(msg)
      @what_to_do.call(self, msg)
    end

    def eof
      send_eof
    end

    def pass_on(msg, what_to_do_next)
      next_destination = @destination.receive(msg)
      Piece.new(next_destination, what_to_do_next)
    end
    def send_eof
      @destination.eof
    end
  end
end
