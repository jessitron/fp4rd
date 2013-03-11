require_relative '../lib/improved_hash.rb'

describe Hash do
  describe 'map_values' do
    let (:start_here) {{ "a" => 4, "b" => "roach" } }

    subject { start_here.map_values &block }

    context 'identity' do
      let(:block) { ->(a) { a } }
      it { should == start_here }
    end

    context 'always banana' do
      let(:block) { ->(a) { "banana" } }

      it 'has all bananas in its values' do
        value_equals_banana = ->(a) { a[1].should == "banana" }
        subject.each_pair &value_equals_banana
      end
    end
  end
end
