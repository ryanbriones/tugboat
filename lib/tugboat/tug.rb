require 'optparse'
require 'fileutils'

require 'tugboat/configuration'

module Tugboat
  class Tug
    attr_reader :options, :command, :command_args, :config
    def initialize
      @options = {}
      @command = nil
      @command_args = []
      @config = nil
    end
    
    def self.run(argv)
      tug = self.new
      tug.parse(argv)
      tug.load_config
      
      return Command.send(tug.command.to_sym, tug)
    end
    
    def load_config
      load(File.expand_path("~/.tugboat.conf")) if File.exists?(File.expand_path("~/.tugboat.conf"))
      @config = Tugboat::Configuration.get
    end

    def parse(argv)
      OptionParser.new do |opts|
        # for future use
        
        opts.parse!(argv)
      end

      @command = argv.shift
      @command_args += argv
    end

    def inspect
      "#<Tugboat::Tug:#{object_id} @command=#{@command.inspect} @command_args=#{@command_args.inspect} @options=#{@options.inspect}>"
    end

    class Command
      def self.setup(tug)
        appname = tug.command_args.shift
        unless appname && !appname.empty?
          puts "You must specific an APP_NAME: tug setup [OPTIONS] APP_NAME"
          return 1
        end

        tug.config.application("#{appname}")

        app_path = "~/.tugboat/#{appname}"
        FileUtils.mkdir_p File.expand_path(app_path)
        FileUtils.mkdir %w( releases shared ).map { |dir| File.expand_path(File.join(app_path, dir)) }
        
        File.open(File.expand_path('~/.tugboat.conf'), 'w') do |config|
          config.write tug.config.dump_configuration
        end
        
        return 0
      end
    end
  end
end
