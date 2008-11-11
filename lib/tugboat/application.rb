require 'tugboat/configurable'

module Tugboat
  class Application
    KNOWN_TYPES = [:git, :svn, :tarball]

    tugboat_configurable
    
    attr_accessor :name
    configuration_option :source, :type, :app_path, :user, :group

    def initialize(appname)
      self.name = appname
    end

    def type=(new_type)
      unless KNOWN_TYPES.include?(new_type.to_sym)
        STDERR.puts "#{$0}: Unknown source type #{new_type}. Known types: #{KNOWN_TYPES.join(', ')}"
        exit 1
      end

      @type = new_type.to_sym
    end
  end
end
