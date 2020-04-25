require_relative '../types'
require 'dry-struct'
require 'json'

module Models
  class Record < Dry::Struct
    transform_keys(&:to_sym)

    attribute :topic, Types::String
    attribute :schema_id, Types::Integer
    attribute :key, Types::String
    attribute :value, Types::String
  end
end