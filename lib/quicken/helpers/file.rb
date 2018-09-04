module Quicken
  module Helpers
    module File
      def read_file filename
        File.read(filename)
      end

      def write_file filename, content, force:false
        return :file_exists if ::File.exist?(filename) && !force
        file = ::File.new(filename, 'w')
        file.write content
        file.close
        :file_written
      end
    end
  end
end

