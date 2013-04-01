# Now let's try break

fofLambda = lambda { |a, b|  (a > 5) ? a : b}
fofProc = proc { |a, b| break a if a > 5; b}

numbers.reduce(&fofLambda)
numbers.reduce(&fofProc)

class Bookshelf
  include Enumerable
  def initialize(books)
    @books = books
  end

  def each
    books_browsed = 0
    for i in 0...@books.length
      yield @books[i]
      books_browsed += 1
    end
    puts("You have seen #{books_browsed} books. Anything you like?")
  end
end

shelf = Bookshelf.new([1,2,3,6,3,0])
p = lambda { |a| next if (a < 3); puts a }
p2= Proc.new { |a| next a if (a < 3); break 7 if (a > 6); puts a; a }

 shelf.each { |a| next if (a < 3); break if (a > 6); puts a }

# how about in reduce?

