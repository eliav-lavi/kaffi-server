require_relative '../types'
require 'dry-struct'
require 'json'

module Models
  class Message < Dry::Struct
    transform_keys(&:to_sym)

    attribute :id, Types::String

    attribute :payload, Types::Any
    attribute :schema_name, Types::String
    attribute :topic, Types::String
    attribute :key, Types::Any

    def self.build_from(raw_model:, override_id: true)
      id = override_id ? SecureRandom.hex(10) : raw_model['id']
      payload = JSON.parse(raw_model['payload'])
      Models::Message.new(raw_model.merge(id: id, payload: payload))
    end
  end
end