require_relative 'csv_reader'
require_relative 'book_in_stock'

convert_row_to_book = ->(row) { BookInStock.from_row(row) }
read_all_lines = ->(file) { CsvReader.new(file).to_a }

def always(value); ->(a) { value } end
fold_to_price = ->(either) { either.fold(always(0), ->(b) { b.price })}
#fold_to_count_errors = ->(either) { either.fold(left: always(1), right: always(0))}

all_results = ARGV.flat_map(&read_all_lines).map(&convert_row_to_book)
total = all_results.map(&fold_to_price).reduce(:+)
all_errors = all_results.select(&:left?)

puts("Total price on books: #{total}")
puts("#{all_errors.length} lines were rejected")

