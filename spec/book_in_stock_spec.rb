require_relative '../lib/book_in_stock'

describe 'this booky mappy function' do
  let(:input) { { "ISBN" => "42-B49" , "Amount" => 4.69} }

  subject { BookInStock.from_row(input) }

  its(:price) { should == 4.69 }

  its(:isbn) { should == '42-B49' }
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
