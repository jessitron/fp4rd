Why should a Rubyist care about functional programming?

Maybe objects aren't the end-all and be-all.

Heck, maybe _freedom_ isn't the end-all and be-all.

There are values from functional programming that are relevant to Ruby. Skip all the terminology and the esoteric category theory stuff, and think about why functional programmers do things the way they do. This is what might be universally relevant.

== Basics of Ruby ==

Start with the PickAxe, Chapter 3. The sample program there parses a simple CSV file about bookstore inventory, puts each line into a BookInStock object, and then performs a simple calculation: total the prices of all books.

The initial commit in this repository is straight out of that chapter in the 2nd edition (Ruby 1.9) of the PickAxe.

=== Mix in a different perspective ===

I'm a Scala developer, with a background in Java and C. I'm used to static typing, immutable data, and methods I can't override in tests. When I plan an approach to the problem, it looks very little like the Ruby approach.

I'm learning a lot from the Ruby community, and hopefully the Ruby community can learn something from me.

== Break it down ==

The example code is oversimplified, of course. To work with it, the first thing I need to do is add tests!

But I hate testing the existing code. It's so _stateful_. Ugh. If I want to test summation of prices, I first have to read in CSV files, because that's all in one stateless object.

Now, my Ruby dev friends tell me no, no, you just inject the state you want! You can control all the things! but that feels dirty to me. In Java we have testing frameworks that will let us do dark magic like overriding final methods or accessing private members. It is a code smell to use them.

Tests guide the design of the code. If code is difficult to test using only techniques that are legal in Java, maybe our code is not as clean as it could be.

From this hypothesis, we have experimented with smaller functions - static functions even (class methods in Ruby) - with no dependencies on internal or external state. We have exposed more data, while making it immune to modification. Our classes have grown smaller.

These constraints have driven us to write cleaner code. Now it is time to take these lessons back to Ruby, to the community that taught us the value of testing. Time to pay back some of that favor.

Therefore, I eschew behavioural testing. No state changes, no external interaction checks. Just input and output. Data in, data out.

=== Baby steps ===

That CsvReader class in the PickAxe did all kinds of things. It maintained a stateful pile of BookInStocks. It opened files, it translated CSV lines to BookInStocks, and it performed a calculation. Separate all the concerns!

==== Concern: read a file ===
My version of CsvReader in Level1_DataInDataOut (todo: link the tag) has one job: read a CSV file. It only reads one, and it gets that filename at construction.

I made the CsvReader class immutable, by duplicating and freezing its input and itself in initialize. In functional, making classes and data immutable is the Right Thing. With all this code whirling around, will something please just hold still?

Testing this, I don't mock Ruby's CSV library. I test my integration with it. In Java-land, we don't mock the standard libraries. For one, we can't. For two, that doesn't prove that I'm using them correctly. If a test doesn't prove anything useful, is it a good test?

==== Concern: translate to instance ====
Translation of CSV rows to BookInStocks becomes a class method. It should be independently testable, not tied to an instance of anything, and BookInStock is a good namespace for it. 

Ruby's dynamic typing comes in handy here; a CSV::Row and a hash behave the same way for all I care, so test input is easy to create. That's be way harder in Scala.

While we're here, I make BookInStock immutable. The thing about that is, you can't test for all the things your method doesn't do. But you can make some things impossible. Static typists, we like our security blankets. Functional programmers call this "reasoning about code." Ruby devs seem more into trusting each other.

==== Concern: calculate ====
Calculation, the part I originally wanted to test. This is another static method on BookInStock, since it operates on a collection of them.

    books.map(&:price).reduce(0){|a,b| a+b}

Even though it's a one-liner, I'm glad I tested it. Turns out reduce returns nil when called on an empty array, unless an initial value is given.

=== Put it back together ===

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

== Is Ruby a functional language? ==

Functional isn't a language to me so much as a set of strategies and values. There is one prerequisite that a language needs to support these strategies: first-class functions. That means functions can be stored in variables, passed as parameters, and returned from other functions.

Ruby has first-class functions: in lambdas.

"And blocks, and Procs!"

No. Blocks and procs are dirty stepchildren. They're not functions; they're chunks of code, and they do crazy things with flow control.

In a lambda, when you say "return," it does the rational, unsurprising thing of returning from the lambda back to wherever it was called. Because lambdas are functions.

Blocks and (non-lambda) Procs are not functions. When "return" or "break" appears in them, they break not from their own scope, but out of scope above them. It's a mess. 

So yes, Ruby supports a functional style, WITH LAMBDAS.

    ->() { "Yay lambdas" }

== Chapter 2: Error handling ==

The difference between a program and software is error handling. (And security, and installation, and UI, and ...) What happens when a line in one of the input CSV files is invalid?

We could raise an exception. But exceptions have a problem - they interrupt the flow of data. 




