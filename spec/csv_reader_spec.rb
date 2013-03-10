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

  subject { CsvReader.new(file_name).to_a }

  its(:length) { should == 1 }

  it 'read something' do
     subject[0]["a"].should == "armadillo"
  end

  it 'gives nil for columns that do not exist in the header' do
    subject[0]["boogerlizard"].should be_nil
  end

  it 'gives :no_value_given for columns that exist but are empty' do
    subject[0]["c"].should == :no_value_given
  end

end

