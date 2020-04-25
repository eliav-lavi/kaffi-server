# kaffi-server
`kaffi-server` is a utility aimed at facilitating producing messages with AVRO schema to Kafka topics **in local development environment**.

## Motivation
While Confluent's [`kafka-avro-console-producer`](https://docs.confluent.io/3.0.0/quickstart.html) is a great tool, sometimes local development cycles call for some more flexibility and this is where `kaffi-server` comes in, offerring an easier way to register AVRO schemas in Confluent's Schema Registry and produce messages using them.

`kaffi-server`, alongside with its complementery UI component, [`kaffi-ui`](https://github.com/eliav-lavi/kaffi-ui), makes it simple to try those Kafka consumers apps you are working on. The server & UI makes it easier to produce messages with AVRO schema by allowing you to register AVRO schemas and then produce messages using simple JSON and reference which schema to use. Hopefully, this should make development a bit easier.

## Setup
1. Make sure essential dependencies are running:
    * Zookeeper
    * Broker
    * Schema Registry
    
    You may want to use [Confluent Platform Quick Start (Docker)](https://docs.confluent.io/current/quickstart/ce-docker-quickstart.html) for easy, dockerized way to get these.
2. Install project's dependencies using `bundle install`
3. Start up the server using `bundle exec rackup --host 0.0.0.0 -p 5876`

## Usage
The easiest way to operate `kaffi-server` is by running the UI offered by [`kaffi-ui`](https://github.com/eliav-lavi/kaffi-ui).

### Standalone Usage
Once `kaffi-server` is up and running, add a schema by sending a `POST` request to `localhost:5876/schema`:
```json
{
	"subject": "Test",
	"content": "{\"type\":\"record\",\"name\":\"Test\",\"fields\":[{\"name\":\"foo\",\"type\":\"double\"},{\"name\":\"bar\",\"type\":\"string\"}]}"
}
```

The response will contain the id for the schema you have jsut created, which is assigned by Schema Registry

Next, you may send a `POST` request to `localhost:5876/record` in order to produce to a topic of your choice using the schema you have just declared:
```json
{
  "topic": "test",
  "schema_id": 1,
	"key": "abc",
  "value": "{\"foo\": 2.3, \"bar\": \"hello there\"}"
}
```
**Note:** Unless exists, the topic will be created after the first message is produced to it, so the first submission is likely to fail with `LeaderNotAvailable` error.

## Configuration
`kaffi-server` comes with default configuration values. To change them, simply edit `config/settings.yml`:
* `broker_host`: URL for Kafka broker
* `client_id`: Name of application
* `schema_registry_host`: URL for Schema Registry
