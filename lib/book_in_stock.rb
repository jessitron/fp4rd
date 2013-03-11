require_relative 'either'

class BookInStock

  attr_reader :isbn, :price

  def initialize(isbn, price)
    @isbn  = isbn
    @price = price == :no_value_given ? price : Float(price)
  end

  def has_a_price?
    price != :no_value_given
  end

  def self.from_row(row)
    isbn = row["ISBN"]
    price = row["Amount"]
    if isbn == nil
      Either.new(error: "ISBN not defined on row #{row}")
    elsif price == nil
      Either.new(error: "Amount not defined on row #{row}")
    else
      Either.new(book: BookInStock.new(isbn, price))
    end
  end

  def self.sum_prices(books)
    sum = ->(a,b) {a+b}
    books.map(&:price).reduce(0,&sum)
  end
end
