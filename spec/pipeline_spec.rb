require_relative '../lib/pipeline'

describe PipelineBuilder do
  describe 'this weird pipeline thing' do
    let(:input) { ["one","two","three"]}
    let(:new_builder) { PipelineBuilder.new(input) }
    let(:builder) { new_builder }

    subject { builder.answer(Monoid.concat).flow().value }

    describe 'can give an answer' do
      let(:input) { ["hello"] }

      it { should == 'hello' }
    end

    describe 'can stop in the middle' do
      let(:builder) { new_builder.take(2) }

      it { should == "onetwo" }
    end

    describe 'can filter' do
      let(:starts_with_t) { ->(s) {s[0] == "t"} }
      let(:builder) { new_builder.keeping(starts_with_t) }

      it { should == "twothree" }
    end

    describe 'can map' do
      let(:reverse) { ->(a) { a.reverse} }
      let(:builder) { new_builder.through(reverse) }
      it { should == "enoowteerht" }
    end
  end

  describe 'interaction with integers' do
    let(:input) { [1,2,3]}
    let(:new_builder) { PipelineBuilder.new(input) }
    let(:builder) { new_builder }

    subject { builder.answer(Monoid.plus).flow().value }

    describe 'can add integers' do
      it { should == 6 }
    end

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
end
