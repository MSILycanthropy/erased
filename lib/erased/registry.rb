# frozen_string_literal: true

module Erased
  class Registry
    class << self
      def register(name, block_class)
        return if blocks[name.to_sym].present?

        raise Error, "`block_class` must include `Erased::Block`" unless block_class.include?(Erased::Block)

        blocks[name.to_sym] = block_class
      end

      def lookup_and_instantiate_from(json)
        json = json.with_indifferent_access
        maybe_block = find_or_register_block(json["block"])

        return if maybe_block.nil?

        maybe_block.send(:parse, json["attributes"])
      end

      def blocks
        @blocks ||= {}.with_indifferent_access
      end

      private

      def find_or_register_block(block_name)
        return blocks[block_name] if blocks[block_name].present?

        block_class = "#{block_name}_block".classify.constantize
        block_class
      end
    end
  end
end
