require 'spec_helper'
require 'unindent'

describe Trinamo::HdfsConverter do
  it 'has been defined' do
    expect(Trinamo::HdfsConverter).not_to be nil
  end

  describe 'default template' do
    before :all do
      Trinamo::Converter.generate_ddl_template('ddl.yml')
    end
    after :all do
      File.delete('ddl.yml') if File.exists?('ddl.yml')
    end

    describe '#convert' do
      shared_examples_for 'converting hdfs' do
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

      context 'when given format on loading' do
        subject { Trinamo::Converter.load('ddl.yml', :hdfs).convert }
        it_behaves_like 'converting hdfs'
      end

      context 'when given format on converting' do
        subject { Trinamo::Converter.load('ddl.yml').convert(:hdfs) }
        it_behaves_like 'converting hdfs'
      end
    end
  end
end
