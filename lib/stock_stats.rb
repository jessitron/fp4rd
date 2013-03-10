require_relative 'csv_reader'
require_relative 'book_in_stock'

convert_row_to_book = ->(row) { BookInStock.from_row(row) }
read_all_lines = ->(file) { CsvReader.new(file).to_a }

all_results = ARGV.flat_map(&read_all_lines).map(&convert_row_to_book)
all_books = all_results.select(&:is_book?).map(&:book)
all_errors = all_results.select(&:is_error?).map(&:error)

total = BookInStock.sum_prices(all_books)

puts("Total price on #{all_books.length} books: #{total}")
puts("#{all_errors.length} lines were rejected")
                                        
