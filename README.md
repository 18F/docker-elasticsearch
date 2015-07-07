# docker-elasticsearch

#### Description:

Elasticsearch on Ubuntu with several useful plugins and a small script which configures the [http-basic](https://github.com/Asquera/elasticsearch-http-basic) plugin with credentials provided via environment variables on the first run. Optionally persists Elasticsearch logs and data to a volume mounted at `/data`.

#### Plugins:

* [aws-cloud](https://github.com/elastic/elasticsearch-cloud-aws)
* [http-basic](https://github.com/Asquera/elasticsearch-http-basic)
* [mapper-attachments](https://github.com/elastic/elasticsearch-mapper-attachments)

#### Usage:

This container image was created for use with the [cf-containers-broker](https://github.com/cf-platform-eng/cf-containers-broker) for Cloud Foundry, but it should run just fine standalone or alongside any orchestrator capable of inserting environment variables.

Launch a container from the image by providing `username`, `password` and an optional volume where the Elasticsearch data and logs will be stored.

```
sudo docker run \
  && -e "ES_USERNAME=username" \
  && -e "ES_PASSWORD=password" \
  && --rm \
  && --name es-test \
  && -v /home/ubuntu/test:/data \
  && ozzyjohnson/elasticsearch
```

Test the running container by creating an index with the provided credentials.

`curl -XPUT -v --user username:password 'CONTAINER_IP_ADDRESS:9200/test'`
