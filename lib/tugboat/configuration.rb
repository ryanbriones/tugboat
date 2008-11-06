require 'tugboat/application'

module Tugboat
  class Configuration
    attr_accessor :applications
    
    def initialize
      self.applications = []
    end

    def self.config
      @singleton_configuration ||= self.new

      yield @singleton_configuration if block_given?
    end

    def self.get
      @singleton_configuration ||= self.new
    end

    def application(appname)
      application = nil
      
      if existing_application = self.applications.select { |a| a.name == appname }.first
        application = existing_application
      else
        new_application =  Tugboat::Application.new(appname)
        yield new_application if block_given?
        self.applications << new_application
        application = new_application
      end
      
      return application
    end

    def dump_configuration
      output_lines = []
      
      output_lines << %Q%Tugboat::Configuration.config do |config|%

      applications.each do |app|
        output_lines << app.dump_configuration('config', 2)
      end
      
      output_lines << 'end'

      return output_lines.join("\n")
    end
  end
end
