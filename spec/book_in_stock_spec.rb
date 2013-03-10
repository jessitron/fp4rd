require_relative '../lib/book_in_stock'

describe 'this booky mappy function when it works' do
  let(:input) { { "ISBN" => "42-B49" , "Amount" => 4.69} }

  subject { BookInStock.from_row(input).book }

  its(:price) { should == 4.69 }

  its(:isbn) { should == '42-B49' }
end

describe 'the book mapper when it does not work' do
  it 'returns error when no ISBN provided' do
     result = BookInStock.from_row( { "Amount" => 5.00 } )
     result.is_error?.should be_true
  end

  it 'returns error when no Amount provided' do
     result = BookInStock.from_row( { "ISBN" => "abc" } )
     result.is_error?.should be_true
  end
end

describe 'price summation' do
  let(:four_dollar_book) { BookInStock.new("4D",4.00) }
  let(:two_fiddy_book) { BookInStock.new("4D",2.50) }

  it 'gives 0 for 0 books' do
    result = BookInStock.sum_prices([])
    result.should == 0.0
  end

  it 'gives 4 for one $4 book' do
    result = BookInStock.sum_prices([four_dollar_book])
    result.should == 4.0
  end

  it 'totals two books' do
    result = BookInStock.sum_prices([four_dollar_book, two_fiddy_book])
    result.should == 6.50
  end
end
