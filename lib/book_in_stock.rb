require 'rubyz'

class BookInStock

  attr_reader :isbn, :price

  def initialize(isbn, price)
    @isbn  = isbn
    @price = Float(price)
  end

  def self.from_row(row)
    isbn = row["ISBN"]
    price = row["Amount"]
    case
    when isbn == nil
      Either.left("ISBN not defined on row #{row}")
    when price == nil
      Either.left("Amount not defined on row #{row}")
    else
      Either.right(BookInStock.new(isbn, price))
    end
  end

  def self.sum_prices(books)
    books.map(&:price).reduce(0){|a,b| a+b}
  end

end
