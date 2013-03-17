require_relative '../lib/pipeline'

describe 'this weird pipeline thing' do
  it 'can give an answer' do
    result = PipelineBuilder.new(["hello"]).answer(Monoid.concat)
    result.flow().value == "hello"
  end

end
