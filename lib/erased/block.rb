# frozen_string_literal: true

module Erased
  module Block
    class Mock
      attr_accessor :block_class

      def initialize(block_class)
        @block_class = block_class
      end

      def render
        @output_buffer = ActionView::OutputBuffer.new

        instance_eval(template)
      end

      private

      def template
        source = block_class.template.source
        short_identifier = block_class.template.path.sub("#{Rails.root}/", "")

        ActionView::Template::Handlers::ERB.call(
          Data.new(format: :html, identifier: block_class.template.path, short_identifier:, type: ActionView::Template::Types[:html]),
          source
        )
      end

      def method_missing(method_name, ...)
        if method_name == :children
          return
        end

        if block_class.attribute_names.include?(method_name.to_sym)
          return "{{#{method_name}}}"
        end

        super
      end

      def respond_to_missing(method_name, include_private = false)
        block_class.attribute_names.include?(method_name.to_sym) || super
      end
    end

    Template = Struct.new(:lineno, :path, :source, keyword_init: true)
    Data = Struct.new(:format, :identifier, :short_identifier, :type, keyword_init: true)

    class << self
      def included(base)
        base.extend(ClassMethods)
      end
    end

    attr_accessor :child_document, :id
    attr_reader :attributes

    def initialize
      @attributes = {}
    end

    def render_in(view_context)
      @view_context = view_context
      @output_buffer = ActionView::OutputBuffer.new

      instance_eval(template)
    end

    def template
      source = self.class.template.source
      short_identifier = self.class.template.path.sub("#{Rails.root}/", "")

      ActionView::Template::Handlers::ERB.call(
        Data.new(format: :html, identifier: self.class.template.path, short_identifier:, type: ActionView::Template::Types[:html]),
        source
      )
    end

    def block_name
      self.class.block_name
    end

    private

    def children
      @view_context.render(child_document)
    end

    module ClassMethods
      def parse(json)
        return new if json.blank?

        json = JSON.parse(json) if json.is_a?(String)
        json = json.with_indifferent_access

        instance = new

        attribute_names.each do |name|
          instance.send("#{name}=", json[:attributes][name])
        end

        if @has_children
          instance.child_document = Document.parse(json[:children])
        end

        instance.id = json[:id] || SecureRandom.hex(8)

        instance
      end

      # DSL
      attr_reader :template

      def erb_template(source)
        caller = caller_locations(1..1)[0]
        @template = Template.new(source:, path: caller.absolute_path || caller.path, lineno: caller.lineno)
      end

      def mrml_template(source)
        raise NotImplementedError
      end

      def has_children
        @has_children = true
      end

      def block_name(name = nil)
        @block_name ||= if name.present?
          name.to_sym
        else
          self.name.demodulize.underscore.gsub("_block", "").to_sym
        end
      end

      def attribute(name, **options)
        define_method(name) { @attributes[name] }
        define_method("#{name}=") { |value| @attributes[name] = value }

        attribute_names << name.to_sym
        require_attribute_names << name if options[:required]
      end

      def require_attribute_names
        @require_attribute_names ||= []
      end

      def attribute_names
        @attribute_names ||= []
      end

      def mock
        @mock = Mock.new(self)
      end
    end
  end
end
