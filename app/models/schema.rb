require_relative '../types'
require 'dry-struct'

module Models
  class Schema < Dry::Struct
    transform_keys(&:to_sym)

    attribute :subject, Types::String
    attribute :schema, Types::Any
  end
end

