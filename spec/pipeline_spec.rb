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

  it 'can split the pipe' do
    double = ->(a) { a * 2}
    result = PipelineBuilder.new([1,2,3]).
      split({ total: ->(a) {a.answer(Monoid.plus)},
              double_the_first: ->(a) {a.take(1).through(double).answer(Monoid.plus)}})
    answer = result.flow()
    answer.value(:total).should == 6
    answer.value(:double_the_first).should == 2
  end

  it 'can nest splits and follow the paths' do
    result = PipelineBuilder.new(["one","two"]).
      split(first:  ->(a) {a.answer(Monoid.concat)},
            second: ->(a) {a.
        split(third: ->(a) { a.take(1).answer(Monoid.concat)},
               fourth: ->(a) { a.answer(Monoid.concat)}
             )
    })
    output = result.flow()
    output.value(:first).should == "onetwo"
    output.value([:second,:third]).should == "one"
    output.value([:second,:fourth]).should == "onetwo"
  end

  it 'can split immediately after an expansion' do
    array_of_chars = ->(s) {s.each_char}
    is_vowel = ->(c) {"aeiou".include?(c)}
    notnot = ->(p) { ->(a) {!p.call(a)}}
    result = PipelineBuilder.new(["one","two", "three"]).
      expand(array_of_chars).
      split({ vowels: ->(a) {a.keeping(is_vowel).count},
             consonants: ->(a) {a.keeping(notnot.(is_vowel)).count}
      })
    output = result.flow()
    output.value(:vowels).should == 5
    output.value(:consonants).should == 6

  end

end
