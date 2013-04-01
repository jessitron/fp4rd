#
# Summary: the only reliable part is using lambdas and calling them
# with .call.
# Procs, blocks, and yield all screw it up.
#


class CallWithBlock
  attr_reader :after_called
  def initialize
    @after_called = false
  end
  def perform &call_me
    result = call_me.call
    @after_called = true
    result
  end
end

class CallWithYield
  attr_reader :after_called
  def initialize
    @after_called = false
  end
  def perform
    result = yield
    @after_called = true
    result
  end
end

# Block with return: LocalJumpError
describe "return" do
  let(:cwb) { CallWithBlock.new }
  let(:cwy) { CallWithYield.new }
  describe "block that uses return" do
    it "throws LocalJumpError when called with yield" do
      t = cwy
      Proc.new { t.perform { return "stuff" } }.should raise_error(LocalJumpError)
      t.after_called.should be_false
    end
    it "throws LocalJumpError when called with block" do
      t = cwb
      Proc.new { t.perform { return "stuff" } }.should raise_error(LocalJumpError)
      t.after_called.should be_false
    end
    it "Returns and skips the statements after if called inside a lambda" do
      # I don't fully understand why this is different between block and proc
      t = cwb
      lambda { t.perform { return "stuff"}}.call.should == "stuff"
      t.after_called.should be_false
    end
  end

  describe "proc that uses return" do
    let(:p) { Proc.new { return "stuff"}}
    it "throws LocalJumpError when called with yield in a proc" do
      t = cwy
      Proc.new { t.perform &p }.should raise_error(LocalJumpError)
      t.after_called.should be_false
    end
    it "throws LocalJumpError when called with block in a proc" do
      t = cwb
      Proc.new { t.perform &p }.should raise_error(LocalJumpError)
      t.after_called.should be_false
    end
    it "throws LocalJumpError even when called inside a lambda" do
      t = cwb
      lambda { t.perform &p }.should raise_error(LocalJumpError)
      t.after_called.should be_false
    end
  end

  describe "rspec" do
    it "works  on a lambda return; it's using block.call" do
      lambda { return "stuff"}.should_not raise_error(LocalJumpError)
    end
  end

  describe "lambda" do
    let(:lam) { lambda { return "stuff"}}
    it "returns correctly when called as a block" do
      t=cwb
      t.perform(&lam).should == "stuff"
      t.after_called.should be_true
    end
    it "throws LocalJumpError when called with yield" do
      t = cwy
      Proc.new { t.perform(&lam) }.should raise_error(LocalJumpError)
      t.after_called.should be_false
    end
  end

end
