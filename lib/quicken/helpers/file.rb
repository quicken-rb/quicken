module Quicken
  module Helpers
    module File
      def read_file filename
      end

      def write_file filename, content
        return :file_exists if ::File.exist?(filename)
        file = ::File.new(filename, 'w')
        file.write content
        file.close
        return :file_written
      end
    end
  end
end
