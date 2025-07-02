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
      view_context.safe_join(blocks.map do |block|
        view_context.tag.div data: { 'erased-block': block.id, 'erased-block-name': block.class.block_name } do
          block.render_in(view_context)
        end
      end)
    end

    def flat_blocks
      blocks.flat_map do |block|
        if block.child_document.present?
          [ block, *block.child_document.flat_blocks ]
        else
          [ block ]
        end
      end
    end

    private

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
