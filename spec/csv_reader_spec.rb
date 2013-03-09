require_relative '../lib/csv_reader'

describe 'my really simple CSV reader' do
  let(:file_name) { 'tempitron' }

  before do
    File.open(file_name, 'w+') do |f|
      f << "a,b,c,d\n"
      f << "armadillo,banana,,dog\n"
    end
  end

  after do
    File.delete file_name
  end

  it 'had better work' do
     result = CsvReader.new(file_name).to_a
     result.length.should == 1
     result[0]["a"].should == "armadillo"
  end

end

