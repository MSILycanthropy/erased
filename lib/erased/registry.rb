# frozen_string_literal: true

module Erased
  class Registry
    class << self
      def clear
        @blocks = nil
      end

      def register(block_classes)
        block_classes = Array.wrap(block_classes)

        block_classes.each do |block_class|
          name = block_class.block_name
          next if blocks[name.to_sym].present?

          raise Error, "`block_class` must include `Erased::Block`" unless block_class.include?(Erased::Block)

          blocks[name.to_sym] = block_class
        end
      end

      def lookup_and_instantiate_from(json)
        json = json.with_indifferent_access
        maybe_block = find_block(json["block"])

        return if maybe_block.nil?

        maybe_block.send(:parse, json)
      end

      def blocks
        @blocks ||= {}.with_indifferent_access
      end

      private

      def find_block(block_name)
        blocks[block_name]
      end
    end
  end
end
