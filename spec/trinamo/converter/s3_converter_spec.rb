require 'spec_helper'
require 'unindent'

describe Trinamo::S3Converter do
  it 'has been defined' do
    expect(Trinamo::S3Converter).not_to be nil
  end

  describe 'default template' do
    before :all do
      Trinamo::Converter.generate_ddl_template('ddl.yml')
    end
    after :all do
      File.delete('ddl.yml') if File.exists?('ddl.yml')
    end

    describe '#convert' do
      shared_examples_for 'converting s3' do
        let(:expected) do
          <<-EXPECTED.unindent
          -- comments_s3
          CREATE EXTERNAL TABLE comments_s3 (
            user_id BIGINT,comment_id BIGINT,title STRING,content STRING,rate DOUBLE
          ) PARTITIONED BY (date STRING)
          ROW FORMAT DELIMITED FIELDS TERMINATED BY '\\t' LINES TERMINATED BY '\\n'
          LOCATION 's3://path/to/s3/table/location';
          EXPECTED
        end

        it { is_expected.to eq expected }
      end

      context 'when given format on loading' do
        subject { Trinamo::Converter.load('ddl.yml', :s3).convert }
        it_behaves_like 'converting s3'
      end

      context 'when given format on converting' do
        subject { Trinamo::Converter.load('ddl.yml').convert(:s3) }
        it_behaves_like 'converting s3'
      end
    end
  end
end
