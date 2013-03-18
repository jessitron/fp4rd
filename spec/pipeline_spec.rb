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

  it 'can add integers' do
    result = PipelineBuilder.new([1,2,3]).answer(Monoid.plus)
    result.flow().value.should == 6
  end

  printing = ->(message, map_func) { ->(a) { puts message; map_func.call(a)} }

  it 'can widen the pipe' do
    array_of_chars = ->(s) {s.each_char}
    is_vowel = ->(c) {"aeiou".include?(c)}
    result = PipelineBuilder.new(["one","two"]).
      expand(array_of_chars).
      keeping(is_vowel).
      answer(Monoid.concat)
    result.flow().value.should == "oeo"
  end
end
