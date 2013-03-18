require_relative 'csv_reader'
require_relative 'book_in_stock'
require_relative 'pipeline'


printing = ->(message, map_func) { ->(a) { puts message; map_func.call(a)} }
convert_row_to_book = ->(row) { BookInStock.from_row(row) }
read_all_lines = ->(file) { CsvReader.new(file).to_a }
reject_no_price = ->(either) do
  if either.invalid? then either
  elsif either.book.has_a_price? then either
  else Either.new(error: "No price on book")
  end
end

#todo: implement partition, cleaner than split and check both sides

pipe = PipelineBuilder.new(ARGV).
  expand(printing.("--- Reading file...",read_all_lines)).
  through(printing.("1. Converting book",convert_row_to_book)).
  through(printing.("2. Checking price",reject_no_price)).
  split({
    :invalid => ->(a) { a.keeping(->(a){a.invalid?}).count},
    :valid => ->(a) {
      a.keeping(printing.("3a. Checking book", ->(a){a.book?})).
      split({ :count => ->(a) {a.count},
              :total => ->(a) { a.
        through(printing.("3b. Extracting book", ->(a){a.book})).
        through(printing.("4. Pricing",->(a){a.price})).
        answer(Monoid.plus)
      }})
  }})

result = pipe.flow()

total = result.value([:valid,:total])
count = result.value([:valid,:count])
errors = result.value(:invalid)

puts("Total price for #{count} books: #{total}")
puts("There were #{errors} invalid lines")

