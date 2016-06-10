require 'unindent'
require_relative './converter/dynamodb_converter'
require_relative './converter/hdfs_converter'
require_relative './converter/s3_converter'
require_relative './converter/option_converter'

module Trinamo
  class Converter
    class << self
      def load(ddl_yaml_path, format)
        case format
          when :hdfs then HdfsConverter.new(ddl_yaml_path)
          when :s3 then S3Converter.new(ddl_yaml_path)
          when :dynamodb then DynamodbConverter.new(ddl_yaml_path)
          when :option || :options then  load_options(ddl_yaml_path)
          else raise "[ERROR] Unknown format: #{format}" unless [:dynamodb, :hdfs, :s3].include(format)
        end
      end

      def load_options(options_yaml_path)
        OptionConverter.new(options_yaml_path)
      end

      def generate_ddl_template(out_file_path = nil)
        template = <<-TEMPLATE.unindent
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
        TEMPLATE

        File.binwrite(out_file_path, template) if out_file_path
        template
      end

      def generate_options_template(out_file_path = nil)
        template = <<-TEMPLATE.unindent
          options:
            dynamodb.throughput.read.percent: 0.5
            hive.exec.compress.output: true
            io.seqfile.compression.type: BLOCK
            mapred.output.compression.codec: com.hadoop.compression.lzo.LzoCodec
        TEMPLATE

        File.binwrite(out_file_path, template) if out_file_path
        template
      end
    end
  end
end