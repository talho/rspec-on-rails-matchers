module Spec
  module Rails
    module Matchers
      class HTMLElementMatcher
        def initialize(spec_scope, tag_name, *args)
          @attributes = args.extract_options!
          @tag_name = tag_name
          @spec_scope = spec_scope
          
          @tag = [@tag_name, extract_id, extract_classes, build_attributes].compact.join
          @matcher = spec_scope.send(:have_tag, @tag, *args)
        end
        
        def matches?(response)
          @matcher.matches?(response)
        end
        
        [:failure_message, :negative_failure_message, :description].each do |method|
          define_method(method) { @matcher.send(method) }
        end
        
      private
        
        def extract_id
          "##{@attributes.delete(:id)}" if @attributes[:id]
        end

        def extract_classes
          classes = case css = @attributes.delete(:class)
          when String
            css.split(' ')
          when Array
            css
          end
          '.' + classes.join('.') if classes
        end
        
        def build_attributes
          @attributes.collect {|attr,value| "[#{attr}='#{value}']" }.join
        end
      end
      
      def have_form_getting_from(url_or_path)
        return simple_matcher("have a form submitting via GET to '#{url_or_path}'") do
          have_tag("form[method=get][action=#{url_or_path}]").matches?(response)
        end
      end
      
      def have_form_posting_to(url_or_path)
        return simple_matcher("have a form submitting via POST to '#{url_or_path}'") do |response|
          have_tag("form[method=post][action=#{url_or_path}]").matches?(response)
        end
      end

      def have_form_putting_to(url_or_path)
        return simple_matcher("have a form submitting via PUT to '#{url_or_path}'") do |response|
          have_tag("form[method=post][action=#{url_or_path}]").matches?(response)
          have_tag("input[name=_method][type=hidden][value=put]").matches?(response)
        end
      end
      
      def have_label_for(model, attribute, text = nil)
        HTMLElementMatcher.new(self, 'label', text, :for => "#{model}_#{attribute}")
      end
      alias_method :with_label_for, :have_label_for
      
      def have_text_area_for(model, attribute)
        HTMLElementMatcher.new(self, 'textarea',
          :id => "#{model}_#{attribute}",
          :name => "#{model}[#{attribute}]")
      end
      alias_method :with_text_area_for, :have_text_area_for
      
      %w(text password checkbox file).each do |input|
        define_method("have_#{input}_field_for") do |model, attribute|
          HTMLElementMatcher.new(self, 'input',
            :type => input,
            :id => "#{model}_#{attribute}",
            :name => "#{model}[#{attribute}]")
        end
        alias_method :"with_#{input}_field_for", :"have_#{input}_field_for"
      end
      
      def have_submit_button(options = {})
        HTMLElementMatcher.new(self, 'input', options.merge(:type => 'submit'))
      end
      alias_method :with_submit_button, :have_submit_button
      
      def have_link_to(url_or_path, text = nil)
        return simple_matcher("have a link to '#{url_or_path}'") do |response|
          have_tag("a[href=#{url_or_path}]", text).matches?(response)
        end
      end
      alias_method :with_link_to, :have_link_to
      
      def content_for(name)
        response.template.instance_variable_get("@content_for_#{name}")
      end
    end
  end
end