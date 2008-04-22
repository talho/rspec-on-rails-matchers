module Spec
  module Rails
    module Matchers
      class BeValid  #:nodoc:

        def matches?(model)
          @model = model
          @model.valid?
        end

        def failure_message
          "#{@model.inspect} expected to be valid but had errors:\n  #{@model.errors.full_messages.join("\n  ")}"
        end

        def negative_failure_message
          "#{@model.inspect} expected to have errors, but it did not"
        end

        def description
          "be valid"
        end

        private
          attr_reader :type, :name, :model
      end

      def be_valid
        BeValid.new
      end

      class HaveErrorOn  #:nodoc:
        def initialize(attribute)
          @attribute=attribute
        end

        def matches?(model)
          @model=model
          @model.valid?
          !@model.errors.on(@attribute).nil?
        end

        def description
          "have error on #{@attribute}"
        end

        def failure_message
          " expected to have error on #{@attribute} but doesn't"
        end

        def negative_failure_message
          "#{@attribute} expected to not have errors, but it had: #{@model.errors.on(@attribute).inspect}"
        end
      end

      def have_error_on(attribute)
        HaveErrorOn.new(attribute)
      end
      
      def validate_presence_of(attribute)
        return simple_matcher("model to validate the presence of #{attribute}") do |model|
          model.send("#{attribute}=", nil)
          !model.valid? && model.errors.invalid?(attribute)
        end
      end

      def validate_length_of(attribute, options)
        if options.has_key? :within
          min = options[:within].first
          max = options[:within].last
        elsif options.has_key? :is
          min = options[:is]
          max = min
        elsif options.has_key? :minimum
          min = options[:minimum]
        elsif options.has_key? :maximum
          max = options[:maximum]
        end
        
        return simple_matcher("model to validate the length of #{attribute} within #{min || 0} and #{max || 'Infinity'}") do |model|
          invalid = false
          if !min.nil? && min >= 1
            model.send("#{attribute}=", 'a' * (min - 1))

            invalid = !model.valid? && model.errors.invalid?(attribute)
          end
          
          if !max.nil?
            model.send("#{attribute}=", 'a' * (max + 1))

            invalid ||= !model.valid? && model.errors.invalid?(attribute)
          end
          invalid
        end
      end

      def validate_uniqueness_of(attribute)
        return simple_matcher("model to validate the uniqueness of #{attribute}") do |model|
          model.class.stub!(:find).and_return(true)
          !model.valid? && model.errors.invalid?(attribute)
        end
      end

      def validate_confirmation_of(attribute)
        return simple_matcher("model to validate the confirmation of #{attribute}") do |model|
          model.send("#{attribute}_confirmation=", 'asdf')
          !model.valid? && model.errors.invalid?(attribute)
        end
      end
    end
  end
end