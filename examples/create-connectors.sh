## A script similar to this can be used to create connectors making sure the endpoints are ready

echo "Waiting for Kafka Connect to start listening on kafka-connect  "
while :; do
    # Check if the connector endpoint is ready
    # If not check again
    curl_status=$(curl -s -o /dev/null -w %{http_code} http://localhost:{{ .Values.servicePort }}/connectors)
    echo -e $(date) "Kafka Connect listener HTTP state: " $curl_status " (waiting for 200)"
    if [ $curl_status -eq 200 ]; then
        break
    fi
    sleep 5
done

echo "======> Creating connectors"
# Send a simple POST request to create the connector
curl -X POST \
    -H "Content-Type: application/json" \
    --data '{
		"name": "MySourceConnector",
  "config": {
    "connector.class": "io.confluent.connect.activemq.ActiveMQSourceConnector",
    "tasks.max": "2",
    "activemq.url": "http://ec2-52-215-94-210.eu-west-1.compute.amazonaws.com",
    "kafka.topic": "sbcp-aync-messaging-poc",
    "jms.destination.name": "sbcp-async-messaging-poc",
    "jms.destination.type": "queue",
    "name": "MySourceConnector",
    "confluent.topic.bootstrap.servers":"ec2-34-241-176-92.eu-west-1.compute.amazonaws.com:9092"
  }
}' http://$CONNECT_REST_ADVERTISED_HOST_NAME:8083/connectors
