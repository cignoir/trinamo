require_relative './base_converter'

module Trinamo
  class HdfsConverter < BaseConverter
    def convert
      ddl_body = @ddl[:tables].map do |h|
        fields = ([h[:hash_key]] + [h[:range_key]] + [h[:attributes]]).flatten.compact
        <<-DDL.unindent
          -- #{Trinamo::Converter.remove_head_underscore(h[:name])}_hdfs
          CREATE TABLE #{Trinamo::Converter.remove_head_underscore(h[:name])}_hdfs (
            #{fields.map { |attr| "#{attr[:name]} #{attr[:type].upcase}" }.join(',')}
          );
        DDL
      end

      ddl_body.join("\n")
    end
  end
end