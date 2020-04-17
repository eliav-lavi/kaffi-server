# kaffi-server
`kaffi-server` is a utility aimed at facilitating producing messages with AVRO schema to Kafka topics in local development environment. While Confluent's [`kafka-avro-console-producer`](https://docs.confluent.io/3.0.0/quickstart.html) is a great tool, sometimes the development cycle calls for some more flexibility and this is where `kaffi-server` comes in, offerring an easier way to declare AVRO schemas and produce messages using them.

## Setup
1. Make sure essential dependencies are running:
    * Zookeeper
    * Broker
    * Schema Registry
    
    You may want to use [Confluent Platform Quick Start (Docker)](https://docs.confluent.io/current/quickstart/ce-docker-quickstart.html) for easy, dockerized way to get these.
2. Install project's dependencies using `bundle install`
3. Start up the server using `bundle exec rackup --host 0.0.0.0 -p 5876`

## Usage
Once `kaffi` is up and running, add a schema by sending a `POST` request to `localhost:5876/schema`:
```json
{
	"name": "Test",
	"content": "{\"type\":\"record\",\"name\":\"Test\",\"fields\":[{\"name\":\"foo\",\"type\":\"double\"},{\"name\":\"bar\",\"type\":\"string\"}]}"
}
```

Next, you may send a `POST` request to `localhost:5876/message` in order to produce to a topic of your choice using the schema you have just declared:
```json
{
	"payload": "{\"foo\": 2.3, \"bar\": \"me me\"}",
	"schema_name": "Test",
	"topic": "test",
	"key": "abc"
}
```
**Note:** By default, the topic will be created after the first message is produced to it (unless it already exists), so the first submission is likely to fail with `LeaderNotAvailable` error.

## Configuration
`kaffi-server` comes with default configuration values. To change them, simply edit `config/settings.yml`:
* `broker_host`: URL for Kafka broker
* `client_id`: Name of application
* `schema_registry_host`: URL for Schema Registry
* `schemas_dir_path`: by default, `kaffi-server` saves submitted AVRO schemas under the `schemas` directory. This is replaceable with another directory under the root directory.