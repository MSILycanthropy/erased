# frozen_string_literal: true

module Erased
  class Document
    attr_accessor :blocks

    def initialize(blocks)
      @blocks = blocks
    end

    # TODO: This is probably not _exactly_ how we wanna do this. We probably,
    # want some toggle for doing email
    def render_in(view_context)
      view_context.safe_join(blocks.map { |b| b.render_in(view_context) })
    end

    class << self
      def parse(array)
        array = JSON.parse(array) if array.is_a?(String)

        blocks = array.map do |block_data|
          Registry.lookup_and_instantiate_from(block_data)
        end

        new(blocks)
      end
    end
  end
end
