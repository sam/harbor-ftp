class Harbor
  module FTP
    class Controller
      
      def self.inherited(target)
        Harbor::FTP::services.set(target.name, target)
      end
      
      # :nodoc:
      # This is an internal method, defined here simply to reduce
      # boiler-plate in writing new Command classes. When
      # Harbor::FTP::Command is inherited, a hook fires passing the
      # new descendant class to this method, which in turn adds a
      # class-method to the Controller class enabling you to define
      # "actions" for that Command. ie:
      #
      # class Example < Harbor::FTP::Controller
      #   list "uploads" do
      #     raise NotImplementedError.new
      #   end
      # end
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