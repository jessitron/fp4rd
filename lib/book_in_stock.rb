#---
# Excerpted from "Programming Ruby",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/ruby3 for more book information.
#---
class BookInStock      
  
  attr_reader :isbn, :price
  
  def initialize(isbn, price)
    @isbn  = isbn
    @price = Float(price)
  end  

  def self.from_row(row)
     BookInStock.new(row["ISBN"], row["Amount"])
  end

  def self.sum_prices(books)
    books.map(&:price).reduce(0){|a,b| a+b}
  end

end
