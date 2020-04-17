require 'sinatra/base'
require 'sinatra/json'
require 'json'
require 'sinatra/config_file'

require 'kafka'
require 'avro_turf/messaging'

require_relative 'models/schema'
require_relative 'models/message'

class App < Sinatra::Application
  configure :production, :development do
    enable :logging
  end

  register Sinatra::ConfigFile
  config_file '../config/settings.yml'

  logger = Logger.new(STDOUT)

  kafka = Kafka.new([settings.broker_host], client_id: settings.client_id)
  avro = AvroTurf::Messaging.new(registry_url: settings.schema_registry_host, schemas_path: settings.schemas_dir_path)

  post '/schema' do
    begin
      request_body = JSON.parse(request.body.read)
      schema = Models::Schema.build_from(raw_model: request_body)
    rescue StandardError => e
      status 400
      json("could not process request. error: #{e}")
    else
      open("#{settings.schemas_dir_path}/#{schema.name}.avsc", 'w') { |f| f.puts schema.content }
      json(schema.attributes)
    end
  end

  post '/message' do
    begin
      request_body = JSON.parse(request.body.read)
      message = Models::Message.build_from(raw_model: request_body)
    rescue StandardError => e
      status 400
      json("could not process request. error: #{e}")
    else
      payload = avro.encode(message.payload, schema_name: message.schema_name)
      kafka.deliver_message(payload, topic: message.topic, key: message.key)

      json(message.attributes)
    end
  end
end
