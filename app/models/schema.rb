require_relative '../types'
require 'dry-struct'

module Models
  class Schema < Dry::Struct
    transform_keys(&:to_sym)

    attribute :id, Types::String

    attribute :name, Types::String
    attribute :content, Types::Any

    def self.build_from(raw_model:, override_id: true)
      id = override_id ? SecureRandom.hex(10) : raw_model['id']
      Models::Schema.new(raw_model.merge(id: id))
    end
  end
end