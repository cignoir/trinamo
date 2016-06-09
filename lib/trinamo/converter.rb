require 'unindent'
require_relative './converter/dynamodb_converter'
require_relative './converter/hdfs_converter'
require_relative './converter/s3_converter'

module Trinamo
  class Converter
    class << self
      def load(ddl_yaml_path, format)
        case format
          when :hdfs then HdfsConverter.new(ddl_yaml_path)
          when :s3 then S3Converter.new(ddl_yaml_path)
          when :dynamodb then DynamodbConverter.new(ddl_yaml_path)
          else raise "[ERROR] Unknown format: #{format}" unless [:dynamodb, :hdfs, :s3].include(format)
        end
      end

      def generate_template(out_file_path = nil)
        template = <<-TEMPLATE.unindent
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
        TEMPLATE

        File.binwrite(out_file_path, template) if out_file_path
        template
      end
    end
  end
end