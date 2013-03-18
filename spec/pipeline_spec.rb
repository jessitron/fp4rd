require_relative '../lib/pipeline'

describe 'this weird pipeline thing' do
  it 'can give an answer' do
    result = PipelineBuilder.new(["hello"]).answer(Monoid.concat)
    result.flow().value == "hello"
  end

  it 'can stop in the middle' do
    result = PipelineBuilder.new(["one", "two", "three","four"]).take(2).answer(Monoid.concat)
    result.flow().value == "onetwo"
  end

end
