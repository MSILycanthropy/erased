# frozen_string_literal: true

module Erased
  class Editor
    attr_accessor :available_blocks, :document

    def initialize(available_blocks: Registry.blocks.values, document:)
      @available_blocks = available_blocks
      @document = document
    end

    # TODO: This is probably not _exactly_ how we wanna do this. We probably,
    # want some toggle for doing email
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

      view_context.tag.div class: "erased-editor" do
        view_context.safe_join([ templates, attributes_script, view_context.render(document) ])
      end
    end
  end
end
