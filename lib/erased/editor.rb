# frozen_string_literal: true

module Erased
  class Editor
    attr_accessor :available_blocks, :document

    def initialize(available_blocks: Registry.blocks.values, document:)
      @available_blocks = available_blocks
      @document = document
    end

    def render_in(view_context)
      templates = view_context.safe_join(available_blocks.map do |ab|
        view_context.tag.template id: "erased-editor-#{ab.block_name.to_s.downcase.dasherize}-block-template" do
          ab.mock.render
        end
      end)

      attributes_script = view_context.tag.script id: "erased-editor-attributes", type: "application/json" do
        available_blocks.to_h do |ab|
          [ ab.block_name, ab.attribute_names ]
        end.to_json.html_safe
      end

      current_blocks_script = view_context.tag.script id: "erased-editor-blocks", type: "application/json" do
        document.flat_blocks.to_h do |block|
          [ block.id, { type: block.block_name, attributes: block.attributes } ]
        end.to_json.html_safe
      end

      adjacency_list_script = view_context.tag.script id: "erased-editor-adjacency", type: "application/json" do
        build_block_adjacency_list.to_json.html_safe
      end

      view_context.safe_join([
        templates,
        current_blocks_script,
        attributes_script,
        adjacency_list_script
      ])
    end

    private

    def build_block_adjacency_list
      adjacency_list = { root: [] }

      adjacency_list[:root] = document.blocks.map(&:id)

      def extract_children(block, list)
        return [] if block.child_document.nil?

        list[block.id] = block.child_document.blocks.map(&:id)

        block.child_document.blocks.each do |child|
          extract_children(child, list)
        end
      end

      document.blocks.each { |block| extract_children(block, adjacency_list) }

      adjacency_list
    end
  end
end
