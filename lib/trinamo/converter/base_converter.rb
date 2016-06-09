require 'yaml'
require 'active_support/core_ext/hash'

module Trinamo
  class BaseConverter
    attr_accessor :ddl_yaml_path, :ddl

    def initialize(ddl_yaml_path)
      @ddl_yaml_path = ddl_yaml_path
      @ddl = YAML.load_file(ddl_yaml_path).deep_symbolize_keys
    end
  end
end