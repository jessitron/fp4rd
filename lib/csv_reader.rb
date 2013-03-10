require 'csv'
require_relative 'improved_hash'

class CsvReader
  include Enumerable
  def initialize(file)
    @file = file.dup
    @file.freeze
    self.freeze
  end

  def each &block
    nil_to_no_value_given = ->(a) { a.nil? ? :no_value_given : a }
    CSV.foreach(@file, headers: true) do |thing|
      block.call(thing.to_hash.map_values &nil_to_no_value_given)
    end
  end
end


