require_relative '../lib/either'

describe Either do
  let ( :some_book ) { BookInStock.new("imtheisbn",4.69) }
  let ( :some_error ) { "Yo yo yo, that stuff doesn't work" }

  subject { described_class.new param }

  context 'has a book' do
    let(:param) { { book: some_book } }

    its(:book) { should == some_book }

    it { should_not be_invalid }

    it { should be_a_book }
  end

  context 'has an error' do
    let(:param) { { error: some_error } }

    its(:error) { should == some_error }

    it { should_not be_a_book }

    it {should be_invalid }
  end

  it "can't hold both" do
    lambda { Either.new(book: some_book, error: some_error) }.should raise_error(ArgumentError)
  end

  it 'refuses to hold neither' do
    lambda { Either.new }.should raise_error(ArgumentError)
  end
end
