module Tugboat
  module Source
    class Tarball
      def initialize(source_url)
        @source_url = source_url
      end

      def download_to(dir, optional_filename = "latest")
        filename = if Tugboat::Source.coerce(@source_url)
                     File.basename(@source_url)
                   else
                     optional_filename + ".tgz"
                   end
        `curl -sL #{@source_url} > #{dir}/#{filename}`
        @downloaded_file = File.join(dir, filename)
      end

      def copy_contents_to(dir)
        `tar -zxf #{@downloaded_file} -C #{dir} --strip 1`
      end
    end
  end
end
