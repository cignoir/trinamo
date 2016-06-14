require 'spec_helper'
require 'unindent'

describe Trinamo::DynamodbConverter do
  it 'has been defined' do
    expect(Trinamo::DynamodbConverter).not_to be nil
  end

  describe 'default template' do
    before :all do
      Trinamo::Converter.generate_ddl_template('ddl.yml')
    end
    after :all do
      File.delete('ddl.yml') if File.exists?('ddl.yml')
    end

    describe '#convert' do
      shared_examples_for 'converting dynamodb' do
        let(:expected) do
          <<-EXPECTED.unindent
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

      context 'when given format on loading' do
        subject { Trinamo::Converter.load('ddl.yml', :dynamodb).convert }
        it_behaves_like 'converting dynamodb'
      end

      context 'when given format on converting' do
        subject { Trinamo::Converter.load('ddl.yml').convert(:dynamodb) }
        it_behaves_like 'converting dynamodb'
      end
    end
  end
end
