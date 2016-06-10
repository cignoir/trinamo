require 'spec_helper'
require 'unindent'

describe Trinamo::OptionConverter do
  it 'has been defined' do
    expect(Trinamo::OptionConverter).not_to be nil
  end

  describe 'default template' do
    before :all do
      Trinamo::Converter.generate_options_template('options.yml')
    end

    after :all do
      File.delete('options.yml') if File.exists?('options.yml')
    end

    shared_examples_for 'loading options' do
      let(:expected) do
        query = <<-EXPECTED.unindent
          SET dynamodb.throughput.read.percent = 0.5;
          SET hive.exec.compress.output = true;
          SET io.seqfile.compression.type = BLOCK;
          SET mapred.output.compression.codec = com.hadoop.compression.lzo.LzoCodec;
        EXPECTED
        query.strip
      end
      it { is_expected.to eq expected }
    end

    describe '#convert' do
      context 'using .load with :option' do
        subject { Trinamo::Converter.load('options.yml', :option).convert }
        it_behaves_like 'loading options'
      end

      context 'using .load_options' do
        subject { Trinamo::Converter.load_options('options.yml').convert }
        it_behaves_like 'loading options'
      end
    end
  end
end
