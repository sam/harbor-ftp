class Harbor
  module FTP
    class Container
      class ServiceRegistration
        class Parameter
          attr_reader :name

          def initialize(type, name)
            @name_to_sym = name.to_sym
            @name = name.to_s.freeze
            @type = type
          end

          def required?
            @type == :req
          end

          def optional?
            @type == :opt
          end

          def varargs?
            @type == :args
          end

          def to_s
            @name
          end

          def to_sym
            @name_to_sym
          end
        end # class Parameter
      end # class ServiceRegistration
    end # class Container
  end # module FTP
end # class Harbor