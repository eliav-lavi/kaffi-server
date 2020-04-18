require 'sinatra/base'
require 'sinatra/json'
require 'json'
require 'sinatra/config_file'
require 'fileutils'

require 'kafka'
require 'avro_turf/messaging'

require_relative 'models/schema'
require_relative 'models/message'

require_relative 'db/table'

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

  FileUtils.mkdir_p(settings.schemas_dir_path)

  logger = Logger.new(STDOUT)

  kafka = Kafka.new([settings.broker_host], client_id: settings.client_id)
  avro = AvroTurf::Messaging.new(registry_url: settings.schema_registry_host, schemas_path: settings.schemas_dir_path)

  schemas_table = Db::Table.new(name: :schemas, logger: logger, indexes: [:name])

  get '/schema' do
    json({ response: schemas_table.all.map(&:attributes) })
  rescue StandardError => e
    status 400
    json({ response: "could not handle request to get all schemas: #{e.message}" })
  end

  post '/schema' do
    begin
      request_body = JSON.parse(request.body.read)
      schema = Models::Schema.build_from(raw_model: request_body)
    rescue StandardError => e
      status 400
      json({ response: "could not process request. error: #{e}" })
    else
      begin  
        schemas_table.insert(record: schema)
        open("#{settings.schemas_dir_path}/#{schema.name}.avsc", 'w') { |f| f.puts schema.content }
        json({ response: schema.attributes })
      rescue StandardError => e
        status 500
        json({ response: "could not process request. error: #{e}" })
      end
    end
  end

  delete '/schema/:id' do
    begin
      id = params['id']
      schema = schemas_table.find(id: id)
      logger.info "found schema to delete: #{schema.attributes}"
    rescue StandardError => e
      status 400
      json({ response: "could not handle request to remove schema: #{e.message}" })
    else
      begin
        schemas_table.delete(id: schema.id)
        file_path = "#{settings.schemas_dir_path}/#{schema.name}.avsc"
        File.delete(file_path) if File.exist?(file_path)

        logger.info("removed schema: #{schema.name}")

        json({ response: schema.attributes })
      rescue StandardError => e
        status 500
        json({ response: "could not handle request to remove schema: #{e.message}" })
      end
    end
  end

  post '/message' do
    begin
      request_body = JSON.parse(request.body.read)
      message = Models::Message.build_from(raw_model: request_body)
    rescue StandardError => e
      status 400
      json({ response: "could not process request. error: #{e}" })
    else
      payload = avro.encode(message.payload, schema_name: message.schema_name)
      kafka.deliver_message(payload, topic: message.topic, key: message.key)

      json({ response: message.attributes })
    end
  end
end
