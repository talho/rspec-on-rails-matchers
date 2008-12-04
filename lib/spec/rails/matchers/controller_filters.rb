class ActionController::Filters::Filter
  # Returns a string which is identical to the ActionController
  # syntax used to add the filter, like "before_filter :admin_required"
  def to_s
    # convert "{:foo=>:bar}" to ":foo => :bar"
    options = @options.inspect.to_s[1..-2].gsub!("=>", " => ")
    returning s = "" do
      s << "#{self.class.to_s.demodulize.underscore} :#{method}"
      s << ", #{options}" unless options.blank?
    end
  end
end


module Spec
  module Rails
    module Matchers

      # An RSpec matcher to help you ensure that your controller filters are correct.
      class HaveFilter #:doc:
        def initialize(filter_type, expected_method)  #:nodoc:
          klass = "action_controller/filters/#{filter_type}_filter".classify.constantize
          @expected = klass.new(:filter, expected_method.to_sym, {})
        end

        def description #:nodoc:
          "have #{@expected}"
        end

        def matches?(controller) #:nodoc:
          @controller = controller
          @controller.class.filter_chain.select { |filter|
            filter.method == @expected.method && filter.kind == @expected.kind &&
            filter.options == @expected.options && filter.class == @expected.class
          }.size == 1
        end

        # :call-seq:
        #   controller.should have_before_filter(expected).with(expected_arguments)
        #   controller.should_not have_before_filter(expected).with(expected_arguments)
        #
        # Adds an argument expectation to the matcher. This is useful for
        # verifying <tt>:only</tt> or <tt>:except</tt> options for controller filters.
        #
        # === Examples
        #
        #   controller.should have_before_filter(:admin_required).with(:except => :show)
        #   controller.should have_before_filter(:decode_params).with(:only => [:create, :update])
        def with(expected_options)
          expected_options.each_pair do |key, value|
            expected_options[key] = [value].flatten.map(&:to_s).to_set
          end
          @expected.instance_variable_set("@options".to_sym, expected_options)
          self
        end

        def failure_message #:nodoc:
          actual_filters = @controller.class.filter_chain.map(&:to_s).uniq.join("\n  ")
          "expected #{@controller.class} to #{description}, but it only has these:\n  #{actual_filters}"
        end

        def negative_failure_message #:nodoc:
          "expected #{@controller.class} to not #{description}, but it did"
        end
      end


      # :call-seq:
      #   controller.should have_before_filter(expected)
      #   controller.should_not have_before_filter(expected)
      #
      # Accepts a symbol method name +expected+, matching against +before_filters+
      # in the the actual filter-chain of +controller+. To match against the
      # options, you can chain HaveFilter#with.
      #
      # === Examples
      #
      #   controller.should have_before_filter(:admin_required)
      #   controller.should have_before_filter(:admin_required).with(:except => :index)
      def have_before_filter(expected_filter_method)
        HaveFilter.new(:before, expected_filter_method)
      end

      # :call-seq:
      #   controller.should have_after_filter(expected)
      #   controller.should_not have_after_filter(expected)
      #
      # Accepts a symbol method name +expected+, matching against +after_filters+
      # in the the actual filter-chain of +controller+. To match against the
      # options, you can chain HaveFilter#with.
      #
      # === Examples
      #
      #   controller.should have_after_filter(:minify_output)
      #   controller.should have_after_filter(:minify_output).with(:only => :index)
      def have_after_filter(expected_filter_method)
        HaveFilter.new(:after, expected_filter_method)
      end

    end
  end
end