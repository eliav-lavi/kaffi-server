require 'dry-struct'

require_relative '../../types'
require_relative '../record_element_base'

module Models
  module RecordElement
    class String < ::Models::RecordElementBase
      transform_keys(&:to_sym)

      attribute :type, Types::String
      attribute :payload, Types::String
    end
  end
end