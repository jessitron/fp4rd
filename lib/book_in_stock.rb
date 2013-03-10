require_relative 'either'

class BookInStock

  attr_reader :isbn, :price

  def initialize(isbn, price)
    @isbn  = isbn
    @price = Float(price)
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
    books.map(&:price).reduce(0){|a,b| a+b}
  end
end
