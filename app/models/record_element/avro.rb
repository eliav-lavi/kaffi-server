require 'dry-struct'

require_relative '../../types'
# require_relative '../record_element_base'

module Models
  module RecordElement
    class Avro < ::Models::RecordElementBase
      transform_keys(&:to_sym)

      attribute :type, Types::String
      attribute :payload, Types::Any
      attribute :schema_id, Types::Integer
    end
  end
end