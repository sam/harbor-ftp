require_relative "service_registration/parameter"

class Harbor
  module FTP
    class Container
      class ServiceRegistration

        attr_reader :name, :service

        def initialize(name, service)
          @name, @service = name, service
          @initializers = Set.new
          @dependencies = []

          if service.is_a?(Class)
            # Handles methods like "def initialize(*)" which JRuby 1.6 defines on BasicObject
            parameters = service.instance_method(:initialize).parameters - [[:rest]]
            parameters.each do |parameter|
              @dependencies << Parameter.new(parameter[0], parameter[1])
            end
          end
        end

        def construct(container)
          if @service.is_a?(Class)
            if @dependencies.empty?
              @service.new
            else
              args = []

              @dependencies.each do |parameter|
                if container.set?(parameter.name)
                  args << container.get(parameter.name)
                elsif parameter.required?
                  args << nil    
                end
              end

              @service.new *args
            end
          else
            @service
          end
        end

      end # class ServiceRegistration
    end # class Container
  end # module FTP
end # class Harbor