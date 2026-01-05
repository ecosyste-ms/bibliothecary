# frozen_string_literal: true

require "bibliothecary/version"
require "bibliothecary"
require "optparse"

module Bibliothecary
  class CLI
    def run
      options = { path: "./" }

      parser = OptionParser.new do |opts|
        opts.banner = "Usage: bibliothecary [options]"
        opts.separator ""
        opts.separator "Parse dependency information from a file or folder of code"
        opts.separator ""

        opts.on("-p", "--path PATH", "Path to file/folder to analyse (default: ./)") do |path|
          options[:path] = path
        end

        opts.on("-v", "--version", "Show version") do
          puts Bibliothecary::VERSION
          exit
        end

        opts.on("-h", "--help", "Show this help") do
          puts opts
          exit
        end
      end

      parser.parse!

      output = Bibliothecary.analyse(options[:path])
      output.each do |file_contents|
        puts "#{file_contents[:path]} (#{file_contents[:platform]})"
        file_contents[:dependencies].group_by { |d| d[:type] }.each do |type, deps|
          puts "  #{type}"
          deps.each do |dep|
            puts "    #{dep[:name]} #{dep[:requirement]}"
          end
          puts
        end
        puts
      end
    end
  end
end
