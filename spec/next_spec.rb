# Summary: next has no effect detected in this test.
# It doesn't seem to bother loop execution at all.

class EachWithBlock
  include Enumerable
  attr_reader :times_around, :after_called
  def initialize
    @after_called = false
    @times_around = 0
  end
  def each &call_me
    raise ArgumentError.new("bad, dont call this again") if @times_around != 0
    (1..3).each do |i|
      call_me.call i
      @times_around += 1
    end
    @after_called = true
    @times_around
  end
end

class EachWithYield
  include Enumerable
  attr_reader :times_around, :after_called
  def initialize
    @after_called = false
  end
  def each
    @times_around = 0
    (1..3).each do |i|
      yield i
      @times_around += 1
    end
    @after_called = true
    @times_around
  end
end


describe "next" do
  let(:cwb) { EachWithBlock.new }
  let(:cwy) { EachWithYield.new }
  describe "block that uses next" do
    it "has no effect when called with yield; but continues loop" do
      t = cwy
      (t.each { |i| next "stuff #{i}" if (i > 1)}).should == 3
      t.after_called.should be_true
    end
    it "has no effect when called with block" do
      t = cwb
      (t.each { |i| next "stuff #{i}" }).should == 3
      t.after_called.should be_true
    end
  end

  describe "proc that uses next" do
    let(:p) { Proc.new { next "stuff"}}
    it "has no effect when called with yield" do
      t = cwy
      ( t.each &p ).should == 3
      t.after_called.should be_true
    end
    it "has no effect when called with block in a proc" do
      t = cwb
      ( t.each &p ).should == 3
      t.after_called.should be_true
    end
  end

  describe "rspec" do
    it "works  on a lambda next; it's using block.call" do
      lambda { next "stuff"}.should_not raise_error(LocalJumpError)
    end
  end

  describe "lambda" do
    let(:lam) { lambda { |i| next "stuff"}}
    it "has no effect when called with block" do
      t=cwb
      t.each(&lam).should == 3
      t.after_called.should be_true
    end
    it "has no effect when called with yield" do
      t = cwy
      t.each(&lam).should == 3
      t.after_called.should be_true
    end
  end

end
