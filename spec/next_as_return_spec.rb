#
# Summary: next is everything we want return to be
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


# Block with next: LocalJumpError
describe "next" do
  let(:cwb) { CallWithBlock.new }
  let(:cwy) { CallWithYield.new }
  describe "block that uses next" do
    it "acts as a return when called with yield" do
      t = cwy
      t.perform { next "stuff" }.should == "stuff"
      t.after_called.should be_true
    end
    it "acts as a return when called with block" do
      t = cwb
      t.perform { next "stuff" }.should == "stuff"
      t.after_called.should be_true
    end
    it "acts as a return if called inside a lambda" do
      t = cwb
      lambda { t.perform { next "stuff"}}.call.should == "stuff"
      t.after_called.should be_true
    end
  end

  describe "proc that uses next" do
    let(:p) { Proc.new { next "stuff"}}
    it "acts as a return when called with yield" do
      t = cwy
      (t.perform &p).should == "stuff"
      t.after_called.should be_true
    end
    it "acts as a return when called with block.call" do
      t = cwb
      (t.perform &p).should == "stuff"
      t.after_called.should be_true
    end
    it "acts as a return when called inside a lambda" do
      t = cwb
      (t.perform &p).should == "stuff"
      t.after_called.should be_true
    end
  end

  describe "rspec" do
    it "works  on a lambda next; it's using block.call" do
      lambda { next "stuff"}.should_not raise_error(LocalJumpError)
    end
  end

  describe "lambda" do
    let(:lam) { lambda { next "stuff"}}
    it "nexts correctly when called as a block" do
      t=cwb
      t.perform(&lam).should == "stuff"
      t.after_called.should be_true
    end
    it "acts as a return when called with yield" do
      t = cwy
      t.perform(&lam).should == "stuff"
      t.after_called.should be_true
    end
  end

end
