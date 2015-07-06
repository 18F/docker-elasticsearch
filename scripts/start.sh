# Exit on any error.
set -e

# Elasticsearch config dir.
CONFIG_DIR=/elasticsearch/config

# Set the required login credentials.
echo "Running setup..."
if [[ -e /.firstrun ]]; then
  echo "Looks like a first run..."
  sed -i -e"s/ES_USER/$ES_USERNAME/" $CONFIG_DIR/elasticsearch.yml
  sed -i -e"s/ES_PASS/$ES_PASSWORD/" $CONFIG_DIR/elasticsearch.yml
  rm /.firstrun
fi

# Make sure our unprivileged user can access the Elasticsearch data.
echo "Preparing to drop root..."
chown -R elasticsearch:elasticsearch /data

# Drop root perms via gosu for security.
echo "Dropping root and starting Elasticsearch..."
exec gosu elasticsearch /elasticsearch/bin/elasticsearch