class Harbor
  module FTP
    module Loggable
      
      def self.included(target)
        unless target.const_defined? :LOG
          target.const_set :LOG, RJack::SLF4J[target]
        end
      end
      
    end # module Loggable
  end # module FTP
end # class Harbor