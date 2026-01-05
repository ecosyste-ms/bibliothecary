# frozen_string_literal: true

module Bibliothecary
  class Configuration
    attr_accessor :ignored_dirs, :ignored_files

    def initialize
      @ignored_dirs = [".git", "node_modules", "bower_components", "vendor", "dist"]
      @ignored_files = []
    end
  end
end
