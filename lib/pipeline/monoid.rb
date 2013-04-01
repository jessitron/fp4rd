module Pipeline
  class Monoid
    attr_reader :zero
    def initialize(zero, add_lambda)
      @zero = zero
      @append = add_lambda
    end
    def append(a,b)
      @append.call(a,b)
    end

    # instances
    def self.concat
      Monoid.new("", ->(a,b) {a + b})
    end
    def self.plus
      Monoid.new(0,  ->(a,b) {a + b})
    end
  end
end
