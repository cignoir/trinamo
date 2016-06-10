require_relative './base_converter'

module Trinamo
  class DynamodbConverter < BaseConverter
    def convert
      ddl_body = @ddl[:tables].map do |h|
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

      ddl_body.join("\n")
    end
  end
end