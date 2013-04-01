require_relative 'result'

module Pipeline
  class SimpleResult
    include Result
    def initialize(value)
      @value = value
    end

    def value
      @value
    end
  end
end
