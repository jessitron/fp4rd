
good= lambda { |a, b| return a if a < b; b }
bad = Proc.new { |a, b| return a if a < b; b }

numbers = [4,6,5,7,2]

printing = ->(fun, *args) { result = fun.call(*args); p result; result}

class Something
  def printResult(*args)
    if block_given? then
      result = yield(*args)
      puts "Got #{result}"
      result
    else
      "No block given"
    end
  end
end

Something.new.printResult { "yay"}

Something.new.printResult(4,3,&good)
Something.new.printResult(4,3,&bad) # this seems to work the same as lambda

# Now let's try break
