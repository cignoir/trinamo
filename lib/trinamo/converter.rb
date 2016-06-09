require 'yaml'
require 'unindent'
require 'active_support/core_ext/hash'

module Trinamo
  class Converter
    class << self
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

      def generate_ddl_ddb(ddl_yml_path)
        yaml = YAML.load_file(ddl_yml_path).deep_symbolize_keys
        read_percent = yaml[:dynamo_read_percent] ? yaml[:dynamo_read_percent] : 0.5

        ddl_header = <<-DDL.unindent
          SET dynamodb.throughput.read.percent = #{read_percent};
          SET hive.exec.compress.output=true;
          SET io.seqfile.compression.type=BLOCK;
          SET mapred.output.compression.codec = com.hadoop.compression.lzo.LzoCodec;
        DDL

        ddl_body = yaml[:tables].map do |h|
          fields = ([h[:hash_key]] + [h[:range_key]] + [h[:attributes]]).flatten.compact
          <<-DDL.unindent
            -- #{h[:name]}_ddb
            CREATE EXTERNAL TABLE #{h[:name]}_ddb (
              #{fields.map { |attr| "#{attr[:name]} #{attr[:type].upcase}" }.join(',')}
            )
            STORED BY 'org.apache.hadoop.hive.dynamodb.DynamoDBStorageHandler'
            TBLPROPERTIES (
              'dynamodb.table.name' = '#{h[:name]}',
              'dynamodb.column.mapping' = '#{fields.map { |attr| "#{attr[:name]}:#{attr[:name]}" }.join(',') }'
            );
          DDL
        end

        ([ddl_header] + ddl_body).join("\n")
      end

      def generate_ddl_s3(ddl_yml_path)
        ddl_body = YAML.load_file(ddl_yml_path).deep_symbolize_keys[:tables].map do |h|
          if h[:s3_location]
            fields = ([h[:hash_key]] + [h[:range_key]] + [h[:attributes]]).flatten.compact
            partitioned_by = h[:s3_partition] ? "PARTITIONED BY (#{h[:s3_partition].map { |attr| "#{attr[:name]} #{attr[:type].upcase}" }.join(',')})" : ''
            <<-DDL.unindent
              -- #{h[:name]}_s3
              CREATE EXTERNAL TABLE #{h[:name]}_s3 (
                #{fields.map { |attr| "#{attr[:name]} #{attr[:type].upcase}" }.join(',')}
              ) #{partitioned_by}
              ROW FORMAT DELIMITED FIELDS TERMINATED BY '\\t' LINES TERMINATED BY '\\n'
              LOCATION '#{h[:s3_location]}';
            DDL
          else
            STDERR.puts "[ERROR] The location of #{h[:name]}_s3 is not found"
            nil
          end
        end

        ddl_body.compact.join("\n")
      end

      def generate_ddl_hdfs(ddl_yml_path)
        ddl_body = YAML.load_file(ddl_yml_path).deep_symbolize_keys[:tables].map do |h|
          fields = ([h[:hash_key]] + [h[:range_key]] + [h[:attributes]]).flatten.compact
          <<-DDL.unindent
            -- #{h[:name]}_hdfs
            CREATE TABLE #{h[:name]}_hdfs (
              #{fields.map { |attr| "#{attr[:name]} #{attr[:type].upcase}" }.join(',')}
            );
          DDL
        end

        ddl_body.join("\n")
      end
    end
  end
end