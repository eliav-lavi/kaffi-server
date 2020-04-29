require 'dry-struct'

require_relative '../types'

module Models
  class RecordElementBase < Dry::Struct
    transform_keys(&:to_sym)

    attribute :type, Types::String
    attribute :payload, Types::Any

    class << self
      def build_from(raw)
        case raw['type']
        when 'string'
          require_relative 'record_element/string'
          Models::RecordElement::String.new(payload: raw['payload'], type: raw['type'])
        when 'avro'
          require_relative 'record_element/avro'
          require 'json'
          validate_json(raw['payload'])
          Models::RecordElement::Avro.new(payload: raw['payload'], schema_id: raw['schema_id'], type: raw['type'])
        else
          raise 'element must be of type `string` or `avro`!'
        end
      end

      def validate_json(raw)
        begin
          JSON.parse(raw)
        rescue  => exception
          raise 'payload must be a valid JSON object'
        end
      end
    end
  end
end