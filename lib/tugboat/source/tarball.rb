require 'net/http'
require 'uri'

module Tugboat
  module Source
    class Tarball
      def initialize(source_url)
        @source_url = source_url
        @limit_redirections = 10
      end

      def download_to(dir, optional_filename = "latest")
        filename = if Tugboat::Source.coerce(@source_url)
                     File.basename(@source_url)
                   else
                     optional_filename + ".tgz"
                   end
        @downloaded_file = File.join(dir, filename)

        File.open(@downloaded_file, "w") do |f|
          where = URI.parse(@source_url)
          http = Net::HTTP.new(where.host, where.port)
          response = http.get(where.request_uri)
          
          redirections = 0
          while Net::HTTPRedirection === response do
            redirections += 1
            raise SourceError.new("Too Many Redirections") unless redirections < @limit_redirections
            
            where_to_next = URI.parse(response['location'])
            http = Net::HTTP.new(where_to_next.host, where_to_next.port)
            response = http.get(where_to_next.request_uri)
          end

          f.write response.body
        end
      end

      def copy_contents_to(dir)
        system("tar -zxf #{@downloaded_file} -C #{dir} --strip 1")
      end
    end
  end
end
