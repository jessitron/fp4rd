require_relative '../lib/pipeline'

describe PipelineBuilder do
  describe 'this weird pipeline thing' do
    let(:input) { ["one","two","three"]}
    let(:new_builder) { PipelineBuilder.new(input) }
    let(:builder) { new_builder }

    subject { builder.answer(Monoid.concat).flow().value }

    describe 'giving an answer' do
      let(:input) { ["hello"] }

      it { should == 'hello' }
    end

    describe 'stopping in the middle' do
      let(:builder) { new_builder.take(2) }

      it { should == "onetwo" }
    end

    describe 'filtering' do
      let(:starts_with_t) { ->(s) {s[0] == "t"} }
      let(:builder) { new_builder.keeping(starts_with_t) }

      it { should == "twothree" }
    end

    describe 'mapping' do
      let(:reverse) { ->(a) { a.reverse} }
      let(:builder) { new_builder.through(reverse) }
      it { should == "enoowteerht" }
    end
  end

  describe 'interacting with integers' do
    let(:input) { [1,2,3]}
    let(:new_builder) { PipelineBuilder.new(input) }
    let(:builder) { new_builder }

    subject { builder.answer(Monoid.plus).flow().value }

    describe 'adding' do
      it { should == 6 }
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
  end

  describe 'interacting with characters' do
    it 'can widen the pipe' do
      array_of_chars = ->(s) {s.each_char}
      is_vowel = ->(c) {"aeiou".include?(c)}
      result = PipelineBuilder.new(["one","two"]).
        expand(array_of_chars).
        keeping(is_vowel).
        answer(Monoid.concat)
      result.flow().value.should == "oeo"
    end

    #         /---------------------\
    #a       /   :allConcatenated    = concatenated: "onetwo"
    # --------    /-----------------/
    #            <           /------------------------\
    # --------    \         /    :onlyFirst | limit(1) = concatenated: "one"
    #        \     ---------    /---------------------/
    #         \   :all         <
    #          \------------    \-------------------\
    #                       \    :concatenatedAgain = concatenated: "onetwo"
    #                        \----------------------/
    it 'can nest splits and follow the paths' do
      result = PipelineBuilder.new(["one","two"]).
        split(allConcatenated:  ->(a) {a.answer(Monoid.concat)},
              all: ->(a) {a.
                split(onlyFirst: ->(a) { a.take(1).answer(Monoid.concat)},
                      concatenatedAgain: ->(a) { a.answer(Monoid.concat)}
                     )
      })
      output = result.flow()
      output.value(:allConcatenated).should == "onetwo"
      output.value([:all,:onlyFirst]).should == "one"
      output.value([:all,:concatenatedAgain]).should == "onetwo"
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
