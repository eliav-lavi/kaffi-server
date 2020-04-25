require_relative '../types'
require 'dry-struct'
require 'json'

module Models
  class SubjectVersion < Dry::Struct
    transform_keys(&:to_sym)

    attribute :subject, Types::String
    attribute :version, Types::Integer
    attribute :id, Types::Integer
    attribute :schema, Types::String
  end
end