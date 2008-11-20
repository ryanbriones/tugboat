require 'tugboat/core_ext/string'

require 'tugboat/source/tarball'

module Tugboat
  module Source
    class UnsupportedTypeError < StandardError; end
    
    def self.build(source_url, source_type = nil)
      source_type ||= self.coerce(source_url)
      return unless source_type
      
      begin
        klass = "Tugboat::Source::#{source_type.to_s.camelize}".constantize
      rescue NameError
        raise UnsupportedTypeError.new(source_type.to_s)
      end
      
      klass.new(source_url)
    end

    def self.coerce(source_url)
      case source_url
      when %r%^git://.+$%, %r%^http://.+\.git$%
        :git
      when %r%^svn(\+ssh)?://.+$%
        :svn
      when %r%^(?:http|file)://.+\.(?:t|tar\.)gz$% 
        :tarball
      else 
        nil
      end
    end
  end
end
