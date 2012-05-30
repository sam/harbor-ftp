class Harbor
  module FTP
    module FileSystems
      class NativeFtpFile
        # :nodoc: This class is here to handle an edge-case
        # for the IBM JVM. It's a port of what was an anonymous
        # class in the original Apache implementation of NativeFtpFile.
        class FileOutputStream < java.io.FileOutputStream
          __persistent__ = true
          def initialize(file, offset)
            @file = java.io.RandomAccessFile.new(file, "rw")
            @file.length = offset
            @file.seek offset
            super(@file.getFD)
          end
          
          def close
            super
            @file.close
          end
        end # class FileOutputStream
      end # class NativeFtpFile
    end # module FileSystems
  end # module FTP
end # class Harbor