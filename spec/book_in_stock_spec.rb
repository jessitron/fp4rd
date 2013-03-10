require_relative '../lib/book_in_stock'

describe BookInStock do
  describe 'this booky mappy function when it works' do
    let(:input) { { "ISBN" => "42-B49" , "Amount" => 4.69} }

    subject { described_class.from_row(input).book }

    its(:price) { should == 4.69 }

    its(:isbn) { should == '42-B49' }
  end

  describe 'the book mapper when it does not work' do
    subject { described_class.from_row param }

    context 'no ISBN is provided' do
      let(:param) { { 'Amount' => 5.00 } }

      it { should be_invalid }
    end

    context 'no amount provided' do
      let(:param) { { 'ISBN' => 'abc' } }

      it { should be_invalid }
    end

    context 'Amount exists but is empty' do
      let(:param) { { 'ISBN' => 'abc', 'Amount' => :no_value_given } }
      it { should_not be_invalid }
      its(:book) { should_not have_a_price }
    end
  end

  describe 'price summation' do
    let(:four_dollar_book) { described_class.new("4D",4.00) }
    let(:two_fiddy_book) { described_class.new("4D",2.50) }

    subject { described_class.sum_prices books }

    context 'no books' do
      let(:books) { [] }
      it { should == 0.0 }
    end

    context 'one $4 book' do
      let(:books) { [four_dollar_book] }

      it { should == 4.0 }
    end

    context 'two books provided' do
      let(:books) { [four_dollar_book, two_fiddy_book] }

      it { should == 6.50 }
    end
  end
end
