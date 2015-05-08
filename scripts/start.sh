CONFIG_DIR=/elasticsearch/config

# Set the required login credentials.
echo "Running setup..."
if [[ -e /.firstrun ]]; then
  echo "Looks like a first run..."
  sed -i -e"s/ES_USER/$ES_USERNAME/" $CONFIG_DIR/elasticsearch.yml
  sed -i -e"s/ES_PASS/$ES_PASSWORD/" $CONFIG_DIR/elasticsearch.yml
  rm /.firstrun
fi

/elasticsearch/bin/elasticsearch
