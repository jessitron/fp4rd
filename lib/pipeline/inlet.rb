module Pipeline
  class Inlet
    def initialize(nextPiece, done_or_not = :done)
      @nextPiece = nextPiece
      @done_or_not = done_or_not
    end

    def flow(source)
      flow_internal(source.each)
    end

    def flow_internal(source)
      result = begin
                 response = @nextPiece.receive(source.next)
                 if (response.result?) then
                   response
                 else #it's another piece
                   Inlet.new(response, @done_or_not).flow_internal(source)
                 end
               rescue StopIteration
                 if (@done_or_not == :done) then
                   @nextPiece.eof
                 else
                   @nextPiece
                 end
               end
    end
  end
end

