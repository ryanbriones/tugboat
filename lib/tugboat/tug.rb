require 'optparse'

require 'tugboat'
require 'tugboat/configuration'

module Tugboat
  class Tug
    attr_accessor :options, :command, :command_args, :config
    
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
        opts.on('-s SOURCE_URL', '--source-url=SOURCE_URL') { |su| @options[:source_url] = su }
        opts.on('--source-type SOURCE_TYPE') { |st| @options[:source_type] = st }
        
        opts.on('--cold') { |c| @options[:cold] = c }
        
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
          STDERR.puts "#{0}: You must specific an APP_NAME: tug setup [OPTIONS] APP_NAME"
          return 1
        end

        tug.config.application(appname.to_s) do |app|
          app.class.configuration_options.each do |opt|
            app.send("#{opt}=".to_sym, tug.options[opt]) unless tug.options[opt].nil?
          end
        end
        
        app_path = "~/.tugboat/#{appname}"
        mkdir_p File.expand_path(app_path)
        mkdir_p %w( releases shared ).map { |dir| File.expand_path(File.join(app_path, dir)) }
        
        File.open(File.expand_path('~/.tugboat.conf'), 'w') do |config|
          config.write tug.config.dump_configuration
        end
                
        return 0
      end

      def self.install(tug)
        tug.options[:cold] = true
        self.update(tug)
      end

      def self.update(tug)
        appname = tug.command_args.shift
        unless appname && !appname.empty?
          STDERR.puts "#{0}: You must specific an APP_NAME: tug update [OPTIONS] APP_NAME"
          return 1
        end
        
        application = tug.config.application(appname.to_s, false)
        unless application
          STDERR.puts "#{0}: That application does not exist"
          return 1
        end
        
        if tug.options[:cold]
          # do things that you do on a cold deploy
        end

        if application.source
          application.create_new_release
          application.symlink_current_release
        else
          STDERR.puts "#{0}: Invalid Source: #{application.source_url}"
          return 1
        end

        return 0
      end
    end
  end
end
