# only passing a block works.
# Procs always LocalJumpError on break
# Lambdas either LocalJumpError or ignore it completely, depending on how they're called

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


describe "break" do
  let(:cwb) { EachWithBlock.new }
  let(:cwy) { EachWithYield.new }
  describe "block that uses break" do
    it "breaks when called with yield" do
      t = cwy
      (t.each { |i| break "stuff #{i}" if (i > 1)}).should == "stuff 2"
      t.after_called.should be_false
      t.times_around.should == 1
    end
    it "breaks when called with block" do
      t = cwb
      (t.each { |i| break "stuff #{i}" }).should == "stuff 1"
      t.after_called.should be_false
      t.times_around.should == 0
    end
    it "Returns and skips the statements after if called inside a lambda" do
      t = cwb
      lambda { t.each { |i| break "stuff #{i}"}}.call.should == "stuff 1"
      t.after_called.should be_false
      t.times_around.should == 0
    end
  end

  describe "proc that uses break" do
    let(:p) { Proc.new { break "stuff"}}
    it "throws LocalJumpError when called with yield in a proc" do
      t = cwy
      Proc.new { t.each &p }.should raise_error(LocalJumpError)
      t.after_called.should be_false
      t.times_around.should == 0
    end
    it "throws LocalJumpError when called with block in a proc" do
      t = cwb
      Proc.new { t.each &p }.should raise_error(LocalJumpError)
      t.after_called.should be_false
      t.times_around.should == 0
    end
    it "throws LocalJumpError even when called inside a lambda" do
      t = cwb
      lambda { t.each &p }.should raise_error(LocalJumpError)
      t.after_called.should be_false
      t.times_around.should == 0
    end
  end

  describe "rspec" do
    it "works  on a lambda break; it's using block.call" do
      lambda { break "stuff"}.should_not raise_error(LocalJumpError)
    end
  end

  describe "lambda" do
    #interesting: lambda checks argument times_around, the others don't care
    let(:lam) { lambda { |i| break "stuff"}}
    it "has no effect when called with block" do
      t=cwb
      t.each(&lam).should == 3
      t.times_around.should == 3
      t.after_called.should be_true
    end
    it "LocalJumpErrors when called with yield" do
      t = cwy
      Proc.new { t.each(&lam) }.should raise_error(LocalJumpError)
      t.after_called.should be_false
      t.times_around.should == 0
    end
  end

end
