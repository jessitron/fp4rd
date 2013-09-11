# Iteratees in Ruby

This solution to the book-inventory problem
includes the important aspects of laziness: not holding everything in
memory, and separating what to do from when to stop.

It avoids mutable state.

This version uses a gem of my own devising, [aqueductron](http://jessitron.github.io/aqueductron/).

For more reading material, see my blog posts about
[Iteratees](http://blog.jessitron.com/2013/04/dataflow-in-ruby.html)
and
[aqueductron](http://blog.jessitron.com/2013/07/aqueductron-toying-with-dataflow-in-ruby.html)
