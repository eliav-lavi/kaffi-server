require 'sinatra/base'
require 'sinatra/json'
require 'json'
require 'sinatra/config_file'
require 'fileutils'

require 'kafka'
require 'avro_turf/messaging'
require 'avro_turf/confluent_schema_registry'

require_relative 'models/schema'
require_relative 'models/subject_version'
require_relative 'models/registered_schema'
require_relative 'models/record'

require_relative 'services/record_element_encoder'

class App < Sinatra::Application
  configure :production, :development do
    enable :logging
  end

  before do
    headers \
      'Access-Control-Allow-Methods' => 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Origin' => '*',
      'Access-Control-Allow-Headers' => 'accept, authorization, origin'
  end

  options '*' do
    response.headers['Allow'] = 'HEAD,GET,PUT,DELETE,OPTIONS,POST'
    response.headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept'
  end

  register Sinatra::ConfigFile
  config_file '../config/settings.yml'

  logger = Logger.new(STDOUT)

  kafka = Kafka.new([settings.broker_host], client_id: settings.client_id)
  avro = AvroTurf::Messaging.new(registry_url: settings.schema_registry_host)
  schema_registry = AvroTurf::ConfluentSchemaRegistry.new(settings.schema_registry_host)

  record_element_encoder = Services::RecordElementEncoder.new(avro: avro)

  get '/schema' do
    subjects = schema_registry.subjects
    schemas = subjects.map { |subject| Models::SubjectVersion.new(schema_registry.subject_version(subject)) }
    json({ response: schemas.map(&:attributes) })
  rescue StandardError => e
    status 400
    json({ response: "could not handle request to get all schemas: #{e.message}" })
  end

  post '/schema' do
    begin
      request_body = JSON.parse(request.body.read)
      schema = Models::Schema.new(request_body)
    rescue StandardError => e
      status 400
      json({ response: "could not process request. error: #{e}" })
    else
      begin  
        registered_schema_id = schema_registry.register(schema.subject, schema.schema)
        registered_schema = Models::RegisteredSchema.build_from(schema: schema, id: registered_schema_id)
        
        json({ response: registered_schema.attributes })
      rescue StandardError => e
        status 500
        json({ response: "could not process request. error: #{e}" })
      end
    end
  end

  post '/record' do
    begin
      request_body = JSON.parse(request.body.read)
      record = Models::Record.build_from(request_body)
    rescue StandardError => e
      status 400
      json({ response: "could not process request. error: #{e}" })
    else
      begin
        produce_key = record_element_encoder.encode(record.key)
        produce_value = record_element_encoder.encode(record.value)

        response = kafka.deliver_message(produce_value, topic: record.topic, key: produce_key)

        json({ response: record.attributes })
      rescue StandardError => e
        status 500
        json({ response: "could not process request. error: #{e}" })     
      end
    end
  end
end
