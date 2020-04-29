require 'dry-struct'
require 'json'

require_relative '../types'
require_relative 'record_element_base'

module Models
  class Record < Dry::Struct
    transform_keys(&:to_sym)

    attribute :topic, Types::String
    attribute :key, Models::RecordElementBase
    attribute :value, Models::RecordElementBase

    class << self
      def build_from(raw)
        Models::Record.new(
          topic: raw['topic'],
          key: Models::RecordElementBase.build_from(raw['key']),
          value: Models::RecordElementBase.build_from(raw['value'])
        )
      end
    end
  end
end