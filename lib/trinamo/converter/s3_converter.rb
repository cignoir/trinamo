require_relative './base_converter'

module Trinamo
  class S3Converter < BaseConverter
    def convert
      ddl_body = @ddl[:tables].map do |h|
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
  end
end