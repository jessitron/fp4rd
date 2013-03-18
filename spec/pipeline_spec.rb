require_relative '../lib/pipeline'

describe 'this weird pipeline thing' do
  it 'can give an answer' do
    result = PipelineBuilder.new(["hello"]).answer(Monoid.concat)
    result.flow().value.should == "hello"
  end

  it 'can stop in the middle' do
    result = PipelineBuilder.new(["one", "two", "three","four"]).take(2).answer(Monoid.concat)
    result.flow().value.should == "onetwo"
  end

  it 'can filter' do
    starts_with_t = ->(s) {s[0] == "t"}
    result = PipelineBuilder.new(["one", "two", "three"]).keeping(starts_with_t).answer(Monoid.concat)
    result.flow().value.should == "twothree"
  end

  it 'can map' do
    reverse = ->(a) { a.reverse}
    result = PipelineBuilder.new(["one", "two"]).through(reverse).answer(Monoid.concat)
    result.flow().value.should == "enoowt"
  end
end
