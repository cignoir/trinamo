require 'spec_helper'
require 'unindent'

describe 'Trinamo::Converter' do
  it 'has been defined' do
    expect(Trinamo::Converter).not_to be nil
  end

  let!(:ddl_template) do
    <<-EXPECTED.unindent
      tables:
        - name: comments
          s3_location: s3://path/to/s3/table/location
          s3_partition:
            - name: date
              type: string
          hash_key:
            - name: user_id
              type: bigint
          range_key:
            - name: comment_id
              type: bigint
          attributes:
            - name: title
              type: string
            - name: content
              type: string
            - name: rate
              type: double
        - name: authors
          hash_key:
            - name: author_id
              type: bigint
          attributes:
            - name: name
              type: string
    EXPECTED
  end

  let!(:options_template) do
    <<-EXPECTED.unindent
      options:
        dynamodb.throughput.read.percent: 0.5
        hive.exec.compress.output: true
        io.seqfile.compression.type: BLOCK
        mapred.output.compression.codec: com.hadoop.compression.lzo.LzoCodec
    EXPECTED
  end

  describe '.generate_ddl_template' do
    subject { Trinamo::Converter.generate_ddl_template('out.yml') }

    context 'when file path given' do
      it { is_expected.to eq ddl_template }
      it 'creates a template file as yaml' do
        expect(File.exists?('out.yml')).to be_truthy
      end
    end

    context 'when file path not given' do
      let(:out_file_path) { nil }
      it { is_expected.to eq ddl_template }
    end

    after :all do
      File.delete('out.yml') if File.exists?('out.yml')
    end
  end

  describe '.generate_options_template' do
    subject { Trinamo::Converter.generate_options_template('out.yml') }

    context 'when file path given' do
      it { is_expected.to eq options_template }
      it 'creates a template file as yaml' do
        expect(File.exists?('out.yml')).to be_truthy
      end
    end

    context 'when file path not given' do
      let(:out_file_path) { nil }
      it { is_expected.to eq options_template }
    end

    after :all do
      File.delete('out.yml') if File.exists?('out.yml')
    end
  end
end