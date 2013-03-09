require 'csv'

class CsvReader
  include Enumerable
  def initialize(file)
    @file = file.dup
    @file.freeze
    self.freeze
  end

  def each &block
    CSV.foreach(@file, headers: true) { |thing| block.call thing }
  end
end
