# frozen_string_literal: true

module Erased
  module Block
    class << self
      def included(base)
        base.extend(ClassMethods)

        Registry.register(base.block_name, base)
      end
    end

    delegate_missing_to :@view_context

    def initialize
      @attributes = {}
    end

    def render_in(view_context)
      @view_context = view_context
      template
    ensure
      @view_context = nil
    end

    def template
      raise NotImplementedError
    end

    module ClassMethods
      def parse(json)
        return new if json.blank?

        json = JSON.parse(json) if json.is_a?(String)
        json = json.with_indifferent_access

        instance = new

        attribute_names.each do |name|
          instance.send("#{name}=", json[name])
        end

        instance
      end

      # DSL
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

        attribute_names << name
        require_attribute_names << name if options[:required]
      end

      def require_attribute_names
        @require_attribute_names ||= []
      end

      def attribute_names
        @attribute_names ||= []
      end
    end
  end
end
