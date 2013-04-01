module Pipeline
  class CompoundResult
    include Result
    def initialize(paths)
      @contents = paths
    end

    def value(*path)
      return self if path.empty?
      (head, *tail) = path
      puts "Nothing found at #{head}" unless @contents[head]
      @contents[head].value(*tail)
    end
  end
end
