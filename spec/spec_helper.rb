$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
Dir[File.join(File.dirname(__FILE__), "..", "lib", "**/*.rb")].each{|f| require f }

require 'trinamo'
