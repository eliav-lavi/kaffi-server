require_relative '../types'
require 'dry-struct'

module Models
  class RegisteredSchema < Schema
    attribute :id, Types::Integer

    def self.build_from(schema:, id:)
      Models::RegisteredSchema.new(schema.attributes.merge(id: id))
    end
  end
end

