# frozen_string_literal: true

require_relative "straw/version"

module Straw
    class Error < StandardError
    end

    class NoMatchingOverloadError < Error
        attr_reader :name, :arity

        def initialize(name:, arity:)
            @method_name = name
            @arity = arity
            super("No matching overload for #{name} with arity #{arity}")
        end
    end

    class UnhandledDefinitionOriginError < Error
        attr_reader :origin
        def initialize(origin)
            @origin = origin
            super(
                "Origin #{origin} is not handled for method or function overloading"
            )
        end
    end

    def overload(method_name)
        original = case self
        when Class
            instance_method(method_name)
        when Module
            method(method_name)
        else
            raise UnhandledDefinitionOriginError.new(self.class.name)
        end

        @overload_definitions ||= Hash.new { |h, k| h[k] = [] }
        @overload_definitions[original.name] << original
        overload_definitions = @overload_definitions
        body = Proc.new do |*args, &blk|
            required_arity = args.length
            selected_method = overload_definitions[method_name].find do |defn|
                defn.arity == required_arity
            end

            if selected_method.nil?
                raise(
                    NoMatchingOverloadError.new(
                        name: method_name.name,
                        arity: required_arity
                    )
                )
            end

            if !self.is_a?(Module)
                selected_method = selected_method.bind(self)
            end

            selected_method.call(*args, &blk)
        end

        case self
        when Class
            define_method(method_name, body)
        when Module
            define_singleton_method(method_name, body)
        end
    end
end
