class Harbor
  module FTP
    module Loggable
      
      def self.included(target)
        target.declare_private_constant :LOG, RJack::SLF4J[target]
      end
      
    end # module Loggable
  end # module FTP
end # class Harbor