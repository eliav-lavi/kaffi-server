require 'json'

module Services
  class RecordElementEncoder
    def initialize(avro:)
      @avro = avro
    end

    def encode(record_element)
      case record_element.type
      when 'string'
        record_element.payload
      when 'avro'
        @avro.encode(JSON.parse(record_element.payload), schema_id: record_element.schema_id)
      end
    end
  end
end