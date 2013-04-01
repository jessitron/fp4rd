module Pipeline
  module PieceCommon
    def flow(source)
      Inlet.new(self).flow_internal(source.each)
    end
    def result?
      false
    end
  end
end
