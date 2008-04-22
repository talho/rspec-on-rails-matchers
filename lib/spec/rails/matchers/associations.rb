module Spec
  module Rails
    module Matchers

      class Association  #:nodoc:

        def initialize(type, name, options = {})
          @type = type
          @name = name
          @options = options
          @errors = []
        end

        def matches?(model)
          @model = model.is_a?(ActiveRecord::Base) ? model.class : model
          
          @association = @model.reflect_on_association(@name)

          unless @association
            @errors << "#{@name} association not defined"
          else
            @association.check_validity!
            unless @association.macro == @type
              @errors << "expected #{@model} to have a #{@type.inspect} association called #{name.inspect}, but got #{@association.macro.inspect}" 
            end
            declared_options = @association.options.reject {|k,| !@options.keys.include?(k) }
            unless declared_options == @options
              @errors << "expected #{@type.inspect} #{@name.inspect} association with #{@options.inspect}, but got #{declared_options.inspect}"
            end
          end
          @errors.empty?
        end

        def failure_message
          @errors.join "\n"
        end

        def description
          "have a #{@type} association called :#{@name}"
        end

      end

      def have_many(name, options = {})
        Association.new(:has_many, name, options)
      end
      
      def belong_to(name, options = {})
        Association.new(:belongs_to, name, options)
      end
      
      def have_and_belong_to_many(name, options = {})
        Association.new(:has_and_belongs_to_many, name, options)
      end

      def have_one(name, options = {})
        Association.new(:has_one, name, options)
      end

    end
  end
end
