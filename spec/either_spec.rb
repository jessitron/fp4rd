require_relative '../lib/either'

describe 'Either class' do
  let ( :some_book ) { BookInStock.new("imtheisbn",4.69) }
  let ( :some_error ) { "Yo yo yo, that stuff doesn't work" }

  it 'can hold a book' do
     result = Either.new(book: some_book)
     result.book.should == some_book
  end

  it 'can hold an error' do
    result = Either.new(error: some_error)
    result.error.should == some_error
  end

  it 'knows when it has has no book' do
    result = Either.new(error: some_error)
    result.is_book?.should be_false
  end

  it 'knows when it has no error' do
    result = Either.new(book: some_book)
    result.is_error?.should be_false
  end

  it 'knows when it has an error' do
    result = Either.new(error: some_error)
    result.is_error?.should be_true
  end

  it 'knows when it has a book' do
    result = Either.new(book: some_book)
    result.is_book?.should be_true
  end

  it "can't hold both" do
    lambda { Either.new(book: some_book, error: some_error) }.should raise_error(ArgumentError)
  end

  it 'refuses to hold neither' do 
    lambda { Either.new() }.should raise_error(ArgumentError)
  end
end
