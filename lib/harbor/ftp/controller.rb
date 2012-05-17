class Harbor
  module FTP
    class Controller
      
      def self.inherited(target)
        Harbor::FTP::services.set(target.name, target)
      end
      
      def self.register_command(command)
        name = File::basename(Harbor::FTP::underscore(command.name))
        (class << self; self; end).send(:define_method, name) do |*args|
          nil
        end
      end
      
      def initialize(request, response)
        @request = request
        @response = response
      end
    end # class Controller
  end # module FTP
end # class Harbor