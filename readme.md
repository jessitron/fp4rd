#Why should a Rubyist care about functional programming?#

Maybe objects aren't the end-all and be-all.

Heck, maybe _freedom_ isn't the end-all and be-all.

There are values from functional programming that are relevant to Ruby. Skip all the terminology and the esoteric category theory stuff, and think about why functional programmers do things the way they do. This is what might be universally relevant.

Here is the [video of this talk on confreaks](http://www.confreaks.com/videos/2382-rmw2013-functional-principles-for-oo-development)

## Interesting iteratees ##
If you're here to see the solution I referenced in my talk, which
processes files for multiple results without reading them all in at
once, then check the [iteratees branch](https://github.com/jessitron/fp4rd/tree/iteratees).

### Basics of Ruby ###

Start with the PickAxe, Chapter 3. The sample program there parses a simple CSV file about bookstore inventory, puts each line into a BookInStock object, and then performs a simple calculation: total the prices of all books.

The initial commit in this repository is straight out of that chapter in the 2nd edition (Ruby 1.9) of the PickAxe.

### Mix in a different perspective ###

I'm a Scala developer, with a background in Java and C. I'm used to static typing, immutable data, and methods I can't override in tests. When I plan an approach to the problem, it looks very little like the Ruby approach.

I'm learning a lot from the Ruby community, and hopefully the Ruby community can learn something from me.

### Break it down ###

The example code is oversimplified, of course. To work with it, the first thing I need to do is add tests!

But I hate testing the existing code. It's so _stateful_. Ugh. If I want to test summation of prices, I first have to read in CSV files, because that's all in one stateless object.

Now, my Ruby dev friends tell me no, no, you just inject the state you want! You can control all the things! but that feels dirty to me. In Java we have testing frameworks that will let us do dark magic like overriding final methods or accessing private members. It is a code smell to use them.

Tests guide the design of the code. If code is difficult to test using only techniques that are legal in Java, maybe our code is not as clean as it could be.

From this hypothesis, Java devs have experimented with smaller functions - static functions even (class methods in Ruby) - with no dependencies on internal or external state. We have exposed more data, while making it immune to modification. Our classes have grown smaller.

These constraints have driven us to write cleaner code. Now it is time to take these lessons back to Ruby, to the community that taught us the value of testing. Time to pay back some of that favor.

Therefore, I eschew behavioural testing. No state changes, no external interaction checks. Just input and output. Data in, data out.

### Baby steps ###

That CsvReader class in the PickAxe did all kinds of things. It maintained a stateful pile of BookInStocks. It opened files, it translated CSV lines to BookInStocks, and it performed a calculation. Separate all the concerns!

#### Concern: read a file ####
My version of CsvReader in
[Level1_DataInDataOut](https://github.com/jessitron/fp4rd/tree/Level1_DataInDataOut/lib/csv_reader.rb)
has one job: read a CSV file. It only reads one, and it gets that filename at construction.

I made the CsvReader class immutable, by duplicating and freezing its
input and itself in initialize. In functional style, making classes and data immutable is the Right Thing. With all this code whirling around, will something please just hold still?

Testing this, I don't mock Ruby's CSV library. I test my integration with it. In Java-land, we don't mock the standard libraries. For one, we can't. For two, that doesn't prove that I'm using them correctly. If a test doesn't prove anything useful, is it a good test?

#### Concern: translate to instance ####
Translation of CSV rows to BookInStocks becomes a class method. It should be independently testable, not tied to an instance of anything, and BookInStock is a good namespace for it.

Ruby's dynamic typing comes in handy here; a CSV::Row and a hash behave the same way for all I care, so test input is easy to create. That'd be way harder in Scala.

While we're here, I make BookInStock immutable. The thing about that is, you can't test for all the things your method doesn't do. But you can make some things impossible. Static typists, we like our security blankets. Functional programmers call this "reasoning about code." Ruby devs seem more into trusting each other.

#### Concern: calculate ####
Calculation, the part I originally wanted to test. This is another static method on BookInStock, since it operates on a collection of them.

    books.map(&:price).reduce(0){|a,b| a+b}

Even though it's a one-liner, I'm glad I tested it. Turns out reduce returns nil when called on an empty array, unless an initial value is given.

### Put it back together ###

The PickAxe version of calculating the stats has an imperative style.

1. Declare a new reader
2. Loop through the input; pass each one into the reader
3. Call the calculation method on the reader

The state of the data at any time is buried in the implementation of CsvReader.
We used to like that style; we called it encapsulation. But no longer - the trend now is greater visibility of the data. When the data is immutable that's less dangerous. But hey, this is Ruby, who cares about danger?

Ruby devs can get away with choosing freedom over safety. The Ruby culture is strong, and Ruby developers are disciplined. Testing, frequent commits, carefully evolved practices. They trust each other.

Scala is quite the opposite. Especially in library design, we don't trust other teams to do things right. "In the early iterations of our framework, we looked at what the users did that caused problems. Then we used the type system to make it impossible to do those things."

Right, that was a deviation. Back to putting it all together, functional style.

1. Start with the list of files (from the command line)
2. Turn each of those into a whole bunch of CSV::Rows, combining into one array (flat_map does this)
3. Turn each line into a BookInStock
4. Pass those into the price-summing function

This could be a one-liner, but it would be a messy line. Instead, every block that I want to pass into an Enumerable method, I first define it as a lambda. There are two reasons for this: naming it increases clarity, and lambdas are better than blocks. Wait - why?

### Is Ruby a functional language? ###

Functional isn't a language to me so much as a set of strategies and values. There is one prerequisite that a language needs to support these strategies: first-class functions. That means functions can be stored in variables, passed as parameters, and returned from other functions.

Ruby has first-class functions: in lambdas.

"And blocks, and Procs!"

No. Blocks and procs are [dirty stepchildren](http://blog.jessitron.com/2013/03/passing-functions-in-ruby-harder-than.html). They're not functions; they're chunks of code, and they do crazy things with flow control.

In a lambda, when you say "return," it does the rational, unsurprising thing of returning from the lambda back to wherever it was called. Because lambdas are functions.

Blocks and (non-lambda) Procs are not functions. When "return" or "break" appears in them, they break not from their own scope, but out of scope above them. It's a mess.

So yes, Ruby supports a functional style, WITH LAMBDAS.

    ->() { "Yay lambdas" }

### Chapter 2: Error handling ###

The difference between a program and software is error handling. (And security, and installation, and UI, and ...) What happens when a line in one of the input CSV files is invalid?

We could raise an exception. But exceptions have a problem - they interrupt the flow of data. Why, when one line fails, should we stop processing all of them?

In the real world, data quality is low. Don't freak out. Let that piece fall by the wayside and keep going. On the web, if we can't gather every single piece of information for a dashboard page, do we 500 Internal Server Error? I hope not. Display what we can, politely decline the rest, and let the user decide whether it is worth refreshing the page.

A functional way to handle errors is the Either class. Either holds one of two things. In Haskell this is a generic type-parameterized class. For our purposes, Either needs to hold a book or an error message. (I've written it as concretely as possible because its purpose is clearer that way. Mental abstractions are useful immediately, and code abstractions get useful after about 3 repetitive implementations.)

Once the Either class is available, the translation from CSV rows changes to output an Either(book or error). Then, we can select only the books for the price calculations. We can select the errors for reporting. This is the best we can do with inconsistent data.

What we're accomplishing here is gathering information. The information
we're hoping to get is books and their prices. When we can't get a book,
the error message about why is still information. Treating the error as
data instead of catastophe lets us continue gathering what information
we do have, instead of crashing.

There are multiple kinds of errors we can get here. We could be unable
to read the whole file, or lines in the file. Or we could have a line
with some missing information. If we have a book without an ISBN, then
we can still consider the price. If we have a book without a price, then
we can't include it in the total -- that's a different problem. Ideally,
our program outputs all the prices it can total, along with counts of
the ones we could not total and why.

### Chapter 3: Nil is not data. ###

It just isn't. Nil has too many disparate meanings to mean any one
thing.

### Chapter 4: Functional composition ###

In which I decide I want all the steps to print a report that they're
happening, so I can see the execution order. To do this, wrap each of
them in a function that (1) prints a message and (2) calls the wrapped
function. This beats the snot out of going into each function that does
something and telling it to print a message.

### Chapter 5: Laziness ###

Now that I can see the execution order, it's time to mess with it.
The Level4 implementation reads in all the files; maps all the rows;
selects all the rows; etc. This only works if all the data fits in
memory at once.
Say it doesn't - say we want to read each file line by line,
accumulating the total price as we go, and then forgetting that line so
that we don't run out of memory.

add ".lazy" after our first Enumerable and bam, we're done. Now files
are read one at a time and lines are parsed one at a time.

The negative is, if after that I decide to count the errors, all the
reading happens again.

### Chapter 6: Pipeline ###

So I implement a funny-looking framework that constructs the whole
pipeline, complete with splits which send the data both ways so it can
be both counted and totaled. The data is pushed through the pipeline
once and all totals are calculated as it goes.

Find this in the [iteratee branch](https://github.com/jessitron/fp4rd/tree/iteratees)

#### and so on
There's more to this, as explained in the talk.
Check the [video on confreaks](http://www.confreaks.com/videos/2382-rmw2013-functional-principles-for-oo-development)



