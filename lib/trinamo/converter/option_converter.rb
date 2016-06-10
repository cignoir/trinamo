require_relative './base_converter'

module Trinamo
  class OptionConverter < BaseConverter
    def convert
      options = @ddl[:options] ? @ddl[:options] : {}

      queries = options.keys.map do |key|
        options[key] ? "SET #{key} = #{options[key]};" : nil
      end

      queries.compact.join("\n")
    end
  end
end