require_relative 'csv_reader'
require_relative 'book_in_stock'

printing = ->(message, map_func) { ->(a) { puts message; map_func.call(a)} }
convert_row_to_book = ->(row) { BookInStock.from_row(row) }
read_all_lines = ->(file) { CsvReader.new(file).to_a }
reject_no_price = ->(either) do
  if either.invalid? then either
  elsif either.book.has_a_price? then either
  else Either.new(error: "No price on book")
  end
end

all_results = ARGV.lazy.
  flat_map(&printing.("--- Reading file...", read_all_lines)).
  map(&printing.("1. Converting book", convert_row_to_book)).
  map(&printing.("2. Checking that price is populated",reject_no_price))

all_books = all_results.
  select(&printing.("3. Taking only valid books",->(a) {a.book?})).
  map(&printing.("3a. Extracting the book from it",->(a) {a.book}))

all_errors = all_results.select(&:invalid?).map(&:error)

puts("  Time to sum!")
total = BookInStock.sum_prices(all_books)

puts("  Counting books")
qty = all_books.count
puts("  Counting errors")
errorCount = all_errors.count

puts("Total price on #{qty} books: #{total}")
puts("#{errorCount} lines were rejected")

