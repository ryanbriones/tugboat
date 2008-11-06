require 'tugboat/configurable'

module Tugboat
  class Application
    has_tugboat_configuration(self)
    
    attr_accessor :name
    configuration_option :app_path, :user, :group

    def initialize(appname)
      self.name = appname
    end
  end
end
