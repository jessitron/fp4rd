
# Either a row or an error message
class Either
  attr_reader :book, :error
  def initialize(book: :none, error: :none)
    raise ArgumentError.new("Either a book or an error please, not both") if (book != :none and error != :none)
    raise ArgumentError.new("Either a book or an error please, please give me one") if (book == :none and error == :none)
    @book = book
    @error = error
  end

  def invalid?
    error != :none
  end

  def book?
    book != :none
  end

end
