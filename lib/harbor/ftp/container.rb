require_relative "container/service_registration"

class Harbor
  module FTP
    ##
    # Harbor::FTP::Container is an inversion of control container for simple
    # dependency injection. For more information on dependency injection, see
    # http://martinfowler.com/articles/injection.html.
    # 
    # This class is a stripped down version of Harbor::Container:
    # https://github.com/sam/harbor/blob/master/lib/harbor/controller.rb
    #
    # It removes some disused methods like #empty?, any deprecated methods,
    # support for initializer blocks, and support for optional arguments on get.
    ##
    class Container

      def initialize #:nodoc:
        @services = {}
        @dependencies = {}
      end

      ##
      # Retrieve a service by name from the set of registered services, initializing
      # any dependencies from the container.
      # 
      #   class Controller
      #     attr_accessor :request, :response, :mailer
      #   end
      # 
      #   services.get("Controller")
      ##
      def get(name)
        raise ArgumentError.new("#{name} is not a registered service name") unless set?(name)
        service_registration = @services[name]
        service = service_registration.construct(self)

        dependencies(name).each do |dependency|
          service.send("#{dependency}=", get(dependency))
        end

        service
      end

      def method_missing(method, *args)
        if method.to_s =~ /^(.*)\=$/
          set($1, *args)
        else
          if set?(method.to_s)
            get(method.to_s)
          else
            raise NoMethodError.new("undefined method '#{method}' for #{self}", method)
          end
        end
      end

      ##
      # Register a service by name
      # 
      #   services.set("mail_server", Harbor::SendmailServer.new(:sendmail => "/sbin/sendmail"))
      #   services.set("mailer", Harbor::Mailer)
      #   services.get("mailer") # => #<Harbor::Mailer @from=nil @mail_server=#<SendmailServer...>>
      ##
      def set(name, service)

        type_dependencies = dependencies(name)
        type_methods = service.is_a?(Class) ? service.instance_methods.grep(/\=$/) : []

        @services.values.each do |service_registration|
          if service_registration.service.is_a?(Class) && service_registration.service.instance_methods.include?(:"#{name}=")
            dependencies(service_registration.name) << name
          end

          if type_methods.include?(:"#{service_registration.name}=")
            type_dependencies << service_registration.name
          end
        end

        @services[name] = ServiceRegistration.new(name, service)

        service
      end

      def set?(name)
        @services.key?(name)
      end
    
      private
      def dependencies(service)
        @dependencies[service] ||= Set.new
      end
    end # class Container
  end # module FTP
end # class Harbor