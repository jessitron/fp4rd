#---
# Excerpted from "Programming Ruby",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/ruby3 for more book information.
#---
require_relative 'csv_reader'
require_relative 'book_in_stock'

convert_row_to_book = ->(row) { BookInStock.from_row(row) }
read_all_lines = ->(file) { CsvReader.new(file).to_a }

all_books = ARGV.flat_map(&read_all_lines).map(&convert_row_to_book)

total = BookInStock.sum_prices(all_books)

puts("Total price: #{total}")
                                        
