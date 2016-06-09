require 'spec_helper'
require 'unindent'

describe 'Trinamo::Converter' do
  it 'has been defined' do
    expect(Trinamo::Converter).not_to be nil
  end

  let!(:template) do
    <<-EXPECTED.unindent
      dynamo_read_percent: 0.75
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

  describe '.generate_template' do
    subject { Trinamo::Converter.generate_template('out.yml') }

    context 'when file path given' do
      it { is_expected.to eq template }
      it 'creates a template file as yaml' do
        expect(File.exists?('out.yml')).to be_truthy
      end
    end

    context 'when file path not given' do
      let(:out_file_path) { nil }
      it { is_expected.to eq template }
    end

    after :all do
      File.delete('out.yml') if File.exists?('out.yml')
    end
  end

  describe 'default template' do
    before :all do
      Trinamo::Converter.generate_template('ddl.yml')
    end
    after :all do
      File.delete('ddl.yml') if File.exists?('ddl.yml')
    end

    describe '.generate_ddl_ddb' do
      subject { Trinamo::Converter.load('ddl.yml', :dynamodb).convert }

      let(:expected) do
        <<-EXPECTED.unindent
          SET dynamodb.throughput.read.percent = 0.75;
          SET hive.exec.compress.output=true;
          SET io.seqfile.compression.type=BLOCK;
          SET mapred.output.compression.codec = com.hadoop.compression.lzo.LzoCodec;

          -- comments_ddb
          CREATE EXTERNAL TABLE comments_ddb (
            user_id BIGINT,comment_id BIGINT,title STRING,content STRING,rate DOUBLE
          )
          STORED BY 'org.apache.hadoop.hive.dynamodb.DynamoDBStorageHandler'
          TBLPROPERTIES (
            'dynamodb.table.name' = 'comments',
            'dynamodb.column.mapping' = 'user_id:user_id,comment_id:comment_id,title:title,content:content,rate:rate'
          );

          -- authors_ddb
          CREATE EXTERNAL TABLE authors_ddb (
            author_id BIGINT,name STRING
          )
          STORED BY 'org.apache.hadoop.hive.dynamodb.DynamoDBStorageHandler'
          TBLPROPERTIES (
            'dynamodb.table.name' = 'authors',
            'dynamodb.column.mapping' = 'author_id:author_id,name:name'
          );
        EXPECTED
      end

      it { is_expected.to eq expected }
    end

    describe '.generate_ddl_s3' do
      subject { Trinamo::Converter.load('ddl.yml', :s3).convert }

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

    describe '.generate_ddl_hdfs' do
      subject { Trinamo::Converter.load('ddl.yml', :hdfs).convert }

      let(:expected) do
        <<-EXPECTED.unindent
          -- comments_hdfs
          CREATE TABLE comments_hdfs (
            user_id BIGINT,comment_id BIGINT,title STRING,content STRING,rate DOUBLE
          );

          -- authors_hdfs
          CREATE TABLE authors_hdfs (
            author_id BIGINT,name STRING
          );
        EXPECTED
      end

      it { is_expected.to eq expected }
    end
  end
end