require 'tmpdir'

require 'tugboat/configurable'
require 'tugboat/source'

module Tugboat
  class Application
    tugboat_configurable
    
    attr_accessor :name, :source
    configuration_option :source_url, :source_type, :app_path, :user, :group

    def initialize(appname)
      self.name = appname
    end

    def source_url=(new_source_url)
      @source_url = new_source_url

      self.source = Tugboat::Source.build(@source_url, @source_type)
    end

    def source_type=(new_source_type)
      @source_type = new_source_type.to_sym
      
      self.source = Tugboat::Source.build(@source_url, @source_type) if @source_url && source.nil?
    end

    def source_type
      return @source_type if @source_type
      Tugboat::Source.coerce(@source_url) if @source_url
    end

    def current_release
      @current_release ||= begin
                             Time.now.utc.strftime("%Y%m%d%H%M%S")
                           end
    end

    def release_path
      File.expand_path("~/.tugboat/#{name}/releases/#{current_release}")
    end

    def current_path
      File.expand_path("~/.tugboat/#{name}/current")
    end

    def create_new_release
      mkdir_p(release_path)
      tmp_dir = Dir::tmpdir
      source.download_to(tmp_dir, current_release)
      source.copy_contents_to(release_path)
    end

    def symlink_current_release
      rm_f(current_path) if File.exists?(current_path)
      ln_s(release_path, current_path)
    end
  end
end
