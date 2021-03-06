require 'tempfile'
require 'optparse'

module PuppetGraph
  class CLI
    def run(args)
      parser.parse!(args)

      validate_options

      g = PuppetGraph::Grapher.new
      g.fact_overrides = options[:fact]
      g.modulepath = options[:modulepath]
      g.code = options[:code]
      g.draw(options[:format], options[:output_file])
    end

    private

    def options
      @options ||= {
        :modulepath => 'modules',
      }
    end

    def parser
      @parser ||= OptionParser.new do |opts|
        opts.banner = 'Usage: puppet-graph [options]'

        opts.on '-c', '--code CODE', 'Code to generate a graph of' do |val|
          options[:code] = val
        end

        opts.on '-f', '--fact FACT=VALUE', 'Override a Facter fact' do |val|
          key, value = val.split('=')
          (options[:fact] ||= {})[key] = value
        end

        opts.on '-m', '--modulepath PATH', 'The path to your Puppet modules. Defaults to modules/' do |val|
          options[:modulepath] = val
        end

        opts.on '-o', '--output FILE', 'The file to save the graph to' do |val|
          options[:output_file] = val
          if options[:format].nil?
            options[:format] = File.extname(options[:output_file])[1..-1].to_sym
          end
        end

        opts.on '-r', '--format FORMAT', 'Output format (png or dot). Optional if your output file ends in .dot or .png' do |val|
          options[:format] = val.to_sym
        end

        opts.on_tail '-h', '--help', 'Show this help output' do
          puts parser
          exit 0
        end

        opts.on_tail '-v', '--version', 'Show the version' do
          puts "puppet-graph v#{PuppetGraph::VERSION}"
          exit 0
        end
      end
    end

    def validate_options
      if options[:code].nil?
        $stderr.puts "Error: No Puppet code provided to be graphed."
        $stderr.puts parser
        exit 1
      end

      unless [:dot, :png].include?(options[:format])
        $stderr.puts "Error: Invalid format specified. Valid formats are: dot, png"
        $stderr.puts parser
        exit 1
      end
    end
  end
end
