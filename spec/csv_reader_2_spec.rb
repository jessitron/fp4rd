require_relative '../lib/csv_reader_2'

describe 'my really simple CSV reader' do
  let(:file_name) { 'tempitron' }

  before do
    File.open(file_name, 'w+') do |f|
      f << 'a,b,c,d'
    end
  end

  after do
    File.delete file_name
  end

  it 'had better work' do
     result = CsvReader.new(file_name).to_a
     result.length should equal 0
  end

end
