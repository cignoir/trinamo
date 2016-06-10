require 'yaml'
require 'active_support/core_ext/hash'

module Trinamo
  class BaseConverter
    attr_accessor :ddl_yaml_path, :ddl

    def initialize(ddl_yaml_path, ddl = nil)
      @ddl_yaml_path = ddl_yaml_path
      @ddl = if ddl
        ddl
      else
        ddl_yaml_path ? YAML.load_file(ddl_yaml_path).deep_symbolize_keys : nil
      end
    end

    def convert(format)
      Trinamo::Converter.load(@ddl_yaml_path, format, @ddl).convert
    end
  end
end